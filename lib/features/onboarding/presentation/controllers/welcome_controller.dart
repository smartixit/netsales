import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';

/// متحكم واجهة الترحيب وتحديد الهوية (WelcomeController)
class WelcomeController extends GetxController {
  void goToLogin() {
    Get.toNamed<void>(AppRoutes.login);
  }

  void goToRegisterNetwork() {
    Get.toNamed<void>(AppRoutes.registerNetwork);
  }

  void goToRegisterPos() {
    Get.toNamed<void>(AppRoutes.registerPos);
  }
}
