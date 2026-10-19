import 'package:get/get.dart';
import 'package:netsales/features/onboarding/presentation/controllers/onboarding_controller.dart';

/// ربط اعتماديات جولة التعريف التفاعلية
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<OnboardingController>(OnboardingController());
  }
}
