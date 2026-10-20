import 'package:netsales/features/onboarding/data/models/onboarding_item_model.dart';

/// عقد مصدر البيانات المحلي لجولة التعريف
abstract interface class OnboardingLocalDataSource {
  /// جلب عناصر شرائح جولة التعريف
  List<OnboardingItemModel> getOnboardingItems();

  /// تسجيل إتمام جولة التعريف وحفظ الحالة محلياً
  Future<void> completeOnboarding();
}
