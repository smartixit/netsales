import 'package:netsales/features/onboarding/domain/repositories/onboarding_repository.dart';

/// حالة استخدام إتمام جولة التعريف وحفظ الحالة لعدم ظهورها مجدداً
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  const CompleteOnboardingUseCase(this._repository);

  Future<void> call() {
    return _repository.completeOnboarding();
  }
}
