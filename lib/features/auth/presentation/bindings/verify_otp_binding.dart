import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/request_password_reset_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/verify_reset_otp_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';

/// تسجيل وحقن اعتماديات شاشة التحقق من رمز OTP
class VerifyOtpBinding extends Bindings {
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

    Get.lazyPut<VerifyResetOtpUseCase>(
      () => VerifyResetOtpUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<RequestPasswordResetUseCase>(
      () => RequestPasswordResetUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<VerifyOtpController>(
      () => VerifyOtpController(
        verifyResetOtpUseCase: Get.find<VerifyResetOtpUseCase>(),
        requestPasswordResetUseCase: Get.find<RequestPasswordResetUseCase>(),
      ),
    );
  }
}
