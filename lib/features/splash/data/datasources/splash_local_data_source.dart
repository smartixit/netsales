/// عقد مصدر البيانات المحلي لشاشة الإقلاع
abstract interface class SplashLocalDataSource {
  /// تهيئة خدمات البنية التحتية الأساسية للتطبيق بشكل متوازٍ
  Future<void> initializeInfrastructureServices();

  /// التحقق مما إذا كان التطبيق يُفتح للمرة الأولى
  bool get isFirstLaunch;

  /// التحقق من توفر جلسة مصادقة نشطة محلياً
  bool get isAuthenticated;

  /// التحقق السيادي المباشر من سريان الجلسة مع الخادم عبر مسار /auth/me
  Future<bool> validateSessionWithServer();
}

