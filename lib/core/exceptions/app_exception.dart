/// استثناء عام للتطبيق يعيد الرسالة العربية الصافية دون بادئات برمجية
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  /// تنظيف أي رسالة استثناء من البادئات التقنية مثل Exception: أو StateError:
  /// وضمان عدم ظهور رسائل الأخطاء البرمجية الداخلية مثل Null check operator للمستخدم.
  static String sanitizeMessage(
    dynamic error, {
    String fallback = 'حدث خطأ غير متوقع',
  }) {
    if (error == null) return fallback;

    if (error is AppException) {
      final clean = error.message.trim();
      return clean.isNotEmpty ? clean : fallback;
    }

    String msg = error.toString().trim();

    // إزالة البادئات الشائعة
    const prefixes = [
      'Exception: ',
      'StateError: ',
      'ArgumentError: ',
      'Invalid argument(s): ',
      'Invalid argument: ',
      'FormatException: ',
      'Bad state: ',
      'RangeError: ',
      'Unsupported operation: ',
      'TypeError: ',
      'LateError: ',
      'AssertionError: ',
      'NoSuchMethodError: ',
      'Unhandled Exception: ',
    ];

    for (final prefix in prefixes) {
      if (msg.startsWith(prefix)) {
        msg = msg.substring(prefix.length).trim();
      }
    }

    // فحص الأخطاء البرمجية والتقنية الداخلية لمنع تسريبها للواجهة
    const technicalPatterns = [
      'Instance of ',
      'Null check operator',
      'null check',
      'is not a subtype of',
      'NoSuchMethodError',
      'LateInitializationError',
      'was called on null',
      'NullPointerException',
      'Bad state: No element',
      'Assertion failed',
      'Unhandled Exception',
      'Stack Overflow',
      'ConcurrentModificationError',
      'Out of Memory',
      'PlatformException',
      'MissingPluginException',
    ];

    for (final pattern in technicalPatterns) {
      if (msg.contains(pattern)) {
        return fallback;
      }
    }

    if (msg.isEmpty) {
      return fallback;
    }

    return msg;
  }
}

/// استثناء عدم توفر الصلاحية المطلوبة
class PermissionDeniedException extends AppException {
  const PermissionDeniedException([
    super.message = 'ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء',
    dynamic details,
  ]) : super(code: 'PERMISSION_DENIED', details: details);
}

/// استثناء عدم المصادقة أو انتهاء الجلسة
class UnauthenticatedException extends AppException {
  const UnauthenticatedException([
    super.message = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً',
    dynamic details,
  ]) : super(code: 'UNAUTHENTICATED', details: details);
}



