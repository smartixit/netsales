/// نتيجة التحقق من جلسة محلية محفوظة مع الخادم.
enum SessionValidationResult { valid, unauthorized, forbidden, unavailable }

/// عقد مصدر البيانات المحلي لشاشة الإقلاع.
abstract interface class SplashLocalDataSource {
  Future<void> initializeInfrastructureServices();
  bool get isFirstLaunch;
  bool get isAuthenticated;
  Future<SessionValidationResult> validateSessionWithServer();
}
