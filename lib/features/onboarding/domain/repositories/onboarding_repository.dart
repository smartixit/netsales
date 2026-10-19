/// عقد مستودع جولة التعريف
abstract interface class OnboardingRepository {
  /// تسجيل إتمام جولة التعريف وحفظ الحالة
  Future<void> completeOnboarding();
}
