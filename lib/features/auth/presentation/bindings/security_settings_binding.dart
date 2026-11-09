import 'package:get/get.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/request_two_factor_otp_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/toggle_two_factor_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';

/// ربط تبعيات شاشة إعدادات الأمان والمصادقة الثنائية (SecuritySettingsBinding)
class SecuritySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestTwoFactorOtpUseCase>(
      () => RequestTwoFactorOtpUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<ToggleTwoFactorUseCase>(
      () => ToggleTwoFactorUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<SecuritySettingsController>(
      () => SecuritySettingsController(
        requestTwoFactorOtpUseCase: Get.find<RequestTwoFactorOtpUseCase>(),
        toggleTwoFactorUseCase: Get.find<ToggleTwoFactorUseCase>(),
      ),
    );
  }
}

