/// عقد مستودع الإقلاع لتنسيق تهيئة التطبيق وتحديد وجهة الشاشة الأولى
abstract interface class SplashRepository {
  /// تهيئة خدمات البنية التحتية الأساسية
  Future<void> initializeServices();

  /// تحديد مسار التوجيه التالي بناءً على معايير حالة الإقلاع
  Future<String> getBootDestination();
}

