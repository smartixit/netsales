import 'package:get/get.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source_impl.dart';
import 'package:netsales/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:netsales/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:netsales/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:netsales/features/onboarding/presentations/controllers/onboarding_controller.dart';

/// ربط اعتماديات جولة التعريف التفاعلية
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingLocalDataSource>(
      () => const OnboardingLocalDataSourceImpl(),
    );
    Get.lazyPut<OnboardingRepository>(
      () => OnboardingRepositoryImpl(Get.find<OnboardingLocalDataSource>()),
    );
    Get.lazyPut<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(Get.find<OnboardingRepository>()),
    );
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<CompleteOnboardingUseCase>()),
    );
  }
}
