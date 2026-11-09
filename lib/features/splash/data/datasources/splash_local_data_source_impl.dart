import 'dart:async';
import 'dart:developer';

import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/constants/storage_keys.dart';
import 'package:netsales/core/models/user_model.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/core/services/app_crypto_service.dart';
import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/core/services/internet_connection_service.dart';
import 'package:netsales/core/services/public_settings_service.dart';
import 'package:netsales/core/services/push_notification_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/storage_service.dart';
import 'package:netsales/features/splash/data/datasources/splash_local_data_source.dart';

/// تطبيق مصدر البيانات المحلي لشاشة الإقلاع وتنسيق الخدمات الأساسية
class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  const SplashLocalDataSourceImpl();

  @override
  Future<void> initializeInfrastructureServices() async {
    // تشغيل التهيئة المتوازية للخدمات الأساسية في طبقة البنية التحتية
    await Future.wait([
      DeviceService.instance.init(),
      AppCryptoService.instance.init(),
      PushNotificationService.instance.init(),
      PublicSettingsService.instance.init(),
      InternetConnectionService.instance.initialize(),
    ]);

    // ── Warm-up & Health Check: إيقاظ الخادم وتهيئة اتصال الشبكة مسبقاً ──
    unawaited(_warmUpBackendServer());

    // مزامنة مفاتيح السيرفر السيادية في الخلفية فور جاهزية محرك التشفير
    unawaited(
      AppCryptoService.instance.syncServerPublicKeys(
        dio: ApiService.instance.dio,
      ),
    );

    // تفعيل مراقبة الاتصال الشبكي بعد اكتمال واجهات التطبيق بأمان
    InternetConnectionService.instance.showInternetConnectionState();
  }

  @override
  bool get isFirstLaunch {
    return StorageService.instance.getBool(StorageKeys.isFirstLaunch) ?? true;
  }

  @override
  bool get isAuthenticated {
    return SessionService.to.isAuthenticated;
  }

  @override
  Future<bool> validateSessionWithServer() async {
    // إذا كان الجهاز غير متصل بالإنترنت، لا نعتبر البيانات المخزنة محلياً إثباتاً لجلسة نشطة وموثقة على الخادم
    if (!InternetConnectionService.instance.isConnected) {
      log(
        '⚠️ [Splash] Offline startup: server session cannot be verified authoritatively.',
      );
      return false;
    }

    try {
      final response = await ApiService.instance.get<Map<String, dynamic>>(
        ApiConstants.me,
        fromJson: (json) =>
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      );

      if (response.success && response.data != null) {
        final profileData = response.data!;
        final rawUser = profileData['user'];
        if (rawUser is Map) {
          final updatedUser = UserModel.fromJson({
            ...Map<String, dynamic>.from(rawUser),
            'workspace_roles':
                profileData['workspace_roles'] ?? const <dynamic>[],
            'is_super_admin': profileData['is_super_admin'],
            'role_key': profileData['role_key'],
          });

          final rawPerms = profileData['permissions'];
          final permissions = rawPerms is List
              ? rawPerms.map((e) => e.toString()).toList()
              : const <String>[];

          await SessionService.to.syncSessionProfile(
            user: updatedUser,
            permissions: permissions,
            roleKey: profileData['role_key']?.toString(),
          );
        }
        return true;
      }

      await SessionService.to.terminateSession();
      return false;
    } catch (_) {
      // عند الرفض بـ 401، يقوم معترض ApiService.onUnauthorized بإنهاء الجلسة تلقائياً
      return false;
    }
  }

  /// إيقاظ الخادم وفحص صحته مسبقاً (Warm-up / Health Activity)
  /// يحل مشكلة الـ Cold Start ويفتح اتصال الـ TCP/TLS مسبقاً قبل وصول المستخدم لتسجيل الدخول
  Future<void> _warmUpBackendServer() async {
    try {
      final response = await ApiService.instance.get<Map<String, dynamic>>(
        ApiConstants.healthCheck,
        fromJson: (json) =>
            json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      );
      if (response.success) {
        log(
          '🟢 [Backend Health Warm-up] Server is active & ready: ${response.message}',
        );
      } else {
        log(
          '🟡 [Backend Health Warm-up] Server responded with notice: ${response.message}',
        );
      }
    } catch (e) {
      log(
        '⚠️ [Backend Health Warm-up] Server warm-up ping failed (tolerated): $e',
      );
    }
  }
}
