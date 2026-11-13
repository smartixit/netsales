import 'package:netsales/core/presentation/enums/semantic_tone.dart';

/// حالات ونتائج تشغيل مهام السيرفر ومحرك الاستدراك الذكي (Server Task Catch-up Results)
/// تمثل الحالات المعتمدة لعمليات النبض الدوري واستدراك المهام المجدولة وطوابير المعالجة.
enum ServerTaskResult {
  /// نجاح العملية وتنفيذ المهام المستحقة
  success('SUCCESS', 'تم تشغيل المهام بنجاح', SemanticTone.success),

  /// تخطي: لا تزال فترة التهدئة الزمنية سارية (Throttling Cooldown)
  skippedThrottled(
    'SKIPPED_THROTTLED',
    'تم التخطي: لا تزال فترة التهدئة سارية',
    SemanticTone.neutral,
  ),

  /// تخطي: لا توجد جلسة مصادقة نشطة للمستخدم
  skippedNoSession(
    'SKIPPED_NO_SESSION',
    'تم التخطي: لا توجد جلسة مصادقة نشطة',
    SemanticTone.neutral,
  ),

  /// تخطي: لا يتوفر اتصال فعال بالإنترنت
  skippedNoNetwork(
    'SKIPPED_NO_NETWORK',
    'تم التخطي: لا يتوفر اتصال بالإنترنت',
    SemanticTone.warning,
  ),

  /// تخطي: توجد عملية أخرى قيد المعالجة حالياً (In-App Anti-Overlapping)
  skippedOverlapping(
    'SKIPPED_OVERLAPPING',
    'تم التخطي: توجد مهمة قيد المعالجة حالياً',
    SemanticTone.neutral,
  ),

  /// الخادم مشغول بتنفيذ المهام من عملية أخرى متزامنة (Distributed Lock)
  lockedByServer(
    'LOCKED_BY_SERVER',
    'الخادم مشغول بعملية تشغيل سارية',
    SemanticTone.info,
  ),

  /// تعثر أو فشل في تنفيذ المهام
  failed('FAILED', 'تعثر تشغيل مهام السيرفر', SemanticTone.danger),

  /// حالة غير معروفة
  unknown('UNKNOWN', 'حالة غير معروفة', SemanticTone.neutral);

  const ServerTaskResult(this.wireValue, this.label, this.tone);

  final String wireValue;
  final String label;
  final SemanticTone tone;

  bool get isSuccess => this == ServerTaskResult.success;

  bool get isSkipped =>
      this == ServerTaskResult.skippedThrottled ||
      this == ServerTaskResult.skippedNoSession ||
      this == ServerTaskResult.skippedNoNetwork ||
      this == ServerTaskResult.skippedOverlapping;

  bool get isFailed => this == ServerTaskResult.failed;

  bool get isLocked => this == ServerTaskResult.lockedByServer;

  /// تحليل آمن للقيمة النصية أو السلكية
  static ServerTaskResult fromWire(String? raw) {
    if (raw == null) return ServerTaskResult.unknown;
    final trimmed = raw.trim().toUpperCase();
    for (final item in ServerTaskResult.values) {
      if (item.wireValue == trimmed) return item;
    }
    return ServerTaskResult.unknown;
  }
}

