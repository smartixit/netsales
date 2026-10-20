import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';

/// عقد مستودع جولة التعريف
abstract interface class OnboardingRepository {
  /// جلب عناصر شرائح جولة التعريف
  List<OnboardingItemEntity> getOnboardingItems();

  /// تسجيل إتمام جولة التعريف وحفظ الحالة
  Future<void> completeOnboarding();
}
