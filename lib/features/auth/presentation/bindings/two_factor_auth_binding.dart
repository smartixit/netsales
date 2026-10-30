import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/resend_otp_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/verify_two_factor_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';

/// تسجيل وحقن اعتماديات شاشة التحقق بخطوتين (2FA)
class TwoFactorAuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.lazyPut<AuthRemoteDataSource>(
        () => const AuthRemoteDataSourceImpl(),
      );
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(
        () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      );
    }

    Get.lazyPut<VerifyTwoFactorUseCase>(
      () => VerifyTwoFactorUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<ResendOtpUseCase>(
      () => ResendOtpUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<TwoFactorAuthController>(
      () => TwoFactorAuthController(
        verifyTwoFactorUseCase: Get.find<VerifyTwoFactorUseCase>(),
        resendOtpUseCase: Get.find<ResendOtpUseCase>(),
      ),
    );
  }
}
