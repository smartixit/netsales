import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/enums/server_task_result.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';

/// ============================================================================
/// خدمة مشغل مهام السيرفر ومحرك الاستدراك الذكي (Server Task Runner Service)
/// ============================================================================
/// مسؤولة عن النبض الدوري للواجهة وتشغيل واستدراك المهام المجدولة وطوابير المعالجة
/// على الخادم (Catch-up Engine & Queue Drain) بديلاً عن الـ OS Crontab المستمر.
///
/// الميزات الهندسية:
/// 1. قفل محلي لمنع التداخل (Anti-Overlapping In-App Mutex).
/// 2. قاطع دائرة ذكي وتراجع أسي (Circuit Breaker with Exponential Backoff).
/// 3. تحكم بالتردد وفترات تهدئة (Throttling & Cooldowns).
/// 4. تشغيل متوافق مع النبض الدوري بالواجهة الأمامية والعمليات الخلفية.
class ServerTaskRunnerService extends GetxService {
  ServerTaskRunnerService._();

  static final ServerTaskRunnerService instance = ServerTaskRunnerService._();

  static ServerTaskRunnerService get to =>
      Get.isRegistered<ServerTaskRunnerService>()
          ? Get.find<ServerTaskRunnerService>()
          : instance;

  // ─── الإعدادات الزمنية الافتراضية ───
  /// الحد الأدنى الافتراضي بين كل عملية استدراك (5 دقائق) لمنع إجهاد الخادم
  static const Duration minCatchupInterval = Duration(minutes: 5);

  /// أقصى مدة للتهدئة والتراجع الأسي عند تكرار الفشل (15 دقيقة)
  static const Duration maxBackoffDuration = Duration(minutes: 15);

  // ─── الحالة الداخلية للخدمة ───
  bool _isExecutionLocked = false;
  Timer? _heartbeatTimer;

  /// هل النبض الدوري للواجهة الأمامية نشط حالياً
  bool get isHeartbeatRunning =>
      _heartbeatTimer != null && _heartbeatTimer!.isActive;

  /// هل هناك عملية استدراك قيد المعالجة الآن
  bool get isExecuting => _isExecutionLocked;

  @override
  void onClose() {
    stopForegroundHeartbeat();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. التحكم في النبض الدوري (Foreground Heartbeat)
  // ═══════════════════════════════════════════════════════════════════════════

  /// بدء النبض الدوري الخفيف أثناء استخدام التطبيق
  void startForegroundHeartbeat({
    Duration interval = minCatchupInterval,
  }) {
    if (isHeartbeatRunning) {
      log('⚙️ [ServerTaskRunnerService] النبض الدوري يعمل بالفعل');
      return;
    }

    log(
      '🚀 [ServerTaskRunnerService] بدء النبض الدوري للمهام (كل ${interval.inMinutes} د)',
    );

    // تشغيل نبضة استدراك أولية في الخلفية دون حجب
    unawaited(runCatchupTasks(isForeground: true));

    // جدولة النبض الدوري
    _heartbeatTimer = Timer.periodic(interval, (_) {
      unawaited(runCatchupTasks(isForeground: true));
    });
  }

  /// إيقاف النبض الدوري (عند تعليق التطبيق أو تسجيل الخروج)
  void stopForegroundHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    log('🛑 [ServerTaskRunnerService] تم إيقاف النبض الدوري');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. محرك تشغيل واستدراك المهام (Catch-up Runner)
  // ═══════════════════════════════════════════════════════════════════════════

  /// إرسال نبضة استدراك وتشغيل المهام المستحقة إلى الخادم
  Future<ServerTaskResult> runCatchupTasks({
    bool force = false,
    bool isForeground = false,
    String? task,
  }) async {
    // 1. حماية التداخل المحلي (In-App Mutex Lock)
    if (_isExecutionLocked) {
      log(
        '🔒 [ServerTaskRunnerService] تخطي: توجد مهمة قيد المعالجة حالياً (Anti-Overlapping)',
      );
      return ServerTaskResult.skippedOverlapping;
    }

    _isExecutionLocked = true;

    try {
      // 2. التحقق من وجود جلسة صالحة ومصادقة نشطة
      final session = SessionService.to;
      final sessionId = session.currentSessionId;
      if (!session.isAuthenticated || sessionId == null || sessionId.isEmpty) {
        log('⏭️ [ServerTaskRunnerService] لا توجد جلسة نشطة — تخطي مهام السيرفر');
        return ServerTaskResult.skippedNoSession;
      }

      // 3. التحقق من قاطع الدائرة وحساب التراجع الأسي (Circuit Breaker Backoff)
      if (!force && _isInCircuitBreakerBackoff()) {
        log(
          '⏳ [ServerTaskRunnerService] تخطي: الخادم في فترة التهدئة المؤقتة (Circuit Breaker Backoff)',
        );
        return ServerTaskResult.skippedThrottled;
      }

      // 4. التحقق من انقضاء فترة التهدئة الزمنية العادية (Throttling)
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final storage = StorageService.instance;
      final lastRun = storage.getInt(StorageKeys.lastServerCatchupRun) ?? 0;

      if (!force && (nowMs - lastRun) < minCatchupInterval.inMilliseconds) {
        log(
          '⏱️ [ServerTaskRunnerService] تخطي: لم تنتهِ مهلة التهدئة الدورية بعد',
        );
        return ServerTaskResult.skippedThrottled;
      }

      // 5. التحقق من الاتصال بالإنترنت
      final hasInternet =
          await InternetConnectionService.instance.hasInternet();
      if (!hasInternet) {
        log(
          '🌐 [ServerTaskRunnerService] لا يتوفر اتصال بالإنترنت، تخطي المهام',
        );
        return ServerTaskResult.skippedNoNetwork;
      }

      log('🔄 [ServerTaskRunnerService] جاري إرسال نبضة استدراك المهام للخادم...');

      // 6. استدعاء نقطة النهاية المعتمدة في الخادم (Scheduled Tasks Catch-up Endpoint)
      final response = await ApiService.instance.post<Map<String, dynamic>>(
        ApiConstants.scheduledTasksCatchup,
        data: {
          'force': force,
          if (task != null && task.isNotEmpty) 'task': task,
          'trigger_source': isForeground
              ? 'foreground_heartbeat'
              : 'app_manual_trigger',
        },
        fromJson: (dynamic json) =>
            json is Map<String, dynamic> ? json : <String, dynamic>{},
      );

      if (response.success) {
        await storage.setInt(StorageKeys.lastServerCatchupRun, nowMs);
        await _recordSuccess();

        log(
          '✅ [ServerTaskRunnerService] اكتمل استدراك مهام السيرفر بنجاح: ${response.message}',
        );
        return ServerTaskResult.success;
      } else {
        final message = response.message.toLowerCase();
        final isLocked = message.contains('lock') ||
            message.contains('running') ||
            message.contains('concurrent') ||
            response.message.contains('قيد التنفيذ');

        if (isLocked) {
          log(
            '🔒 [ServerTaskRunnerService] الخادم مشغول بتنفيذ المهام من مصدر متزامن',
          );
          return ServerTaskResult.lockedByServer;
        }

        log(
          '⚠️ [ServerTaskRunnerService] لم تنجح استجابة تشغيل المهام: ${response.message}',
        );
        await _recordFailure();
        return ServerTaskResult.failed;
      }
    } catch (e) {
      log('❌ [ServerTaskRunnerService] خطأ أثناء تشغيل مهام السيرفر: $e');
      await _recordFailure();
      return ServerTaskResult.failed;
    } finally {
      _isExecutionLocked = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. المساعدات وقاطع الدائرة (Circuit Breaker & Helpers)
  // ═══════════════════════════════════════════════════════════════════════════

  /// التحقق مما إذا كانت الخدمة في فترة التراجع الأسي بعد تعثرات متتالية
  bool _isInCircuitBreakerBackoff() {
    final storage = StorageService.instance;
    final failures =
        storage.getInt(StorageKeys.serverCatchupFailuresCount) ?? 0;
    if (failures <= 0) return false;

    final lastRun = storage.getInt(StorageKeys.lastServerCatchupRun) ?? 0;
    if (lastRun == 0) return false;

    // حساب مدة الانتظار: minCatchupInterval * 2^(failures - 1) بحد أقصى maxBackoffDuration
    final multiplier = math.pow(2, math.min(failures - 1, 4)).toInt();
    final backoffMs = math.min(
      minCatchupInterval.inMilliseconds * multiplier,
      maxBackoffDuration.inMilliseconds,
    );

    final elapsed = DateTime.now().millisecondsSinceEpoch - lastRun;
    return elapsed < backoffMs;
  }

  /// تسجيل نجاح وتصفير عداد الأخطاء
  Future<void> _recordSuccess() async {
    final storage = StorageService.instance;
    await storage.setInt(StorageKeys.serverCatchupFailuresCount, 0);
  }

  /// تسجيل فشل لزيادة فترة التراجع الأسي وحماية الخادم
  Future<void> _recordFailure() async {
    final storage = StorageService.instance;
    final failures =
        (storage.getInt(StorageKeys.serverCatchupFailuresCount) ?? 0) + 1;
    await storage.setInt(StorageKeys.serverCatchupFailuresCount, failures);
    await storage.setInt(
      StorageKeys.lastServerCatchupRun,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// تصفير الحالات والمؤقتات وسجلات التخزين (عند تسجيل الخروج)
  Future<void> reset() async {
    stopForegroundHeartbeat();
    _isExecutionLocked = false;
    final storage = StorageService.instance;
    await storage.remove(StorageKeys.lastServerCatchupRun);
    await storage.remove(StorageKeys.serverCatchupFailuresCount);
    log('🧹 [ServerTaskRunnerService] تم تصفير سجلات ومؤقتات مشغل المهام');
  }
}

