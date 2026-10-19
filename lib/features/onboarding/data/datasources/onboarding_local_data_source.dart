/// عقد مصدر البيانات المحلي لجولة التعريف
abstract interface class OnboardingLocalDataSource {
  /// تسجيل إتمام جولة التعريف وحفظ الحالة محلياً
  Future<void> completeOnboarding();
}
