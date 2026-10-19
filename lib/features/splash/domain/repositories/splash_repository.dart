/// عقد مستودع الإقلاع لتحديد وجهة التطبيق الأولى
abstract interface class SplashRepository {
  /// تحديد مسار التوجيه التالي بناءً على معايير حالة الإقلاع
  Future<String> getBootDestination();
}
