import 'package:get/get.dart';
import 'package:netsales/features/onboarding/presentation/controllers/welcome_controller.dart';

/// ربط اعتماديات واجهة الترحيب
class WelcomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WelcomeController>(() => WelcomeController());
  }
}
