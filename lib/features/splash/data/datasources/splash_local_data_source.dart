/// عقد مصدر البيانات المحلي لشاشة الإقلاع
abstract interface class SplashLocalDataSource {
  /// التحقق مما إذا كان التطبيق يُفتح للمرة الأولى
  bool get isFirstLaunch;

  /// التحقق من توفر جلسة مصادقة نشطة
  bool get isAuthenticated;
}
