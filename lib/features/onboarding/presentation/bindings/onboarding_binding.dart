import 'package:get/get.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:netsales/features/onboarding/data/datasources/onboarding_local_data_source_impl.dart';
import 'package:netsales/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:netsales/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:netsales/features/onboarding/domain/usecases/complete_onboarding_use_case.dart';
import 'package:netsales/features/onboarding/domain/usecases/get_onboarding_items_use_case.dart';
import 'package:netsales/features/onboarding/presentation/controllers/onboarding_controller.dart';

/// ربط واعتماد تبعيات جولة التعريف التفاعلية وفق قاعدة التبعية الداخلية
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    // 1. مصدر البيانات المحلي
    Get.lazyPut<OnboardingLocalDataSource>(
      () => const OnboardingLocalDataSourceImpl(),
    );

    // 2. مستودع النطاق
    Get.lazyPut<OnboardingRepository>(
      () => OnboardingRepositoryImpl(Get.find<OnboardingLocalDataSource>()),
    );

    // 3. حالات الاستخدام الدومينية
    Get.lazyPut<GetOnboardingItemsUseCase>(
      () => GetOnboardingItemsUseCase(Get.find<OnboardingRepository>()),
    );
    Get.lazyPut<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(Get.find<OnboardingRepository>()),
    );

    // 4. متحكم العرض
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(
        getOnboardingItemsUseCase: Get.find<GetOnboardingItemsUseCase>(),
        completeOnboardingUseCase: Get.find<CompleteOnboardingUseCase>(),
      ),
    );
  }
}
