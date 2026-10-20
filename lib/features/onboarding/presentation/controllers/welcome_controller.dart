import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';

/// متحكم واجهة الترحيب وتحديد الهوية (WelcomeController)
class WelcomeController extends GetxController {
  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void goToRegisterNetwork() {
    Get.toNamed(AppRoutes.registerNetwork);
  }

  void goToRegisterPos() {
    Get.toNamed(AppRoutes.registerPos);
  }
}
