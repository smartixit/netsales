import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';
import 'package:netsales/features/onboarding/domain/repositories/onboarding_repository.dart';

/// حالة استخدام جلب شرائح جولة التعريف
class GetOnboardingItemsUseCase {
  final OnboardingRepository _repository;

  const GetOnboardingItemsUseCase(this._repository);

  List<OnboardingItemEntity> call() {
    return _repository.getOnboardingItems();
  }
}
