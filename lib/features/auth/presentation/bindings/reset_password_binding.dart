import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/reset_password_controller.dart';

/// تسجيل وحقن اعتماديات شاشة تعيين/تغيير وإعادة تعيين كلمة المرور
class ResetPasswordBinding extends Bindings {
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

    Get.lazyPut<UpdatePasswordUseCase>(
      () => UpdatePasswordUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<ResetPasswordController>(
      () => ResetPasswordController(
        updatePasswordUseCase: Get.find<UpdatePasswordUseCase>(),
        resetPasswordUseCase: Get.find<ResetPasswordUseCase>(),
      ),
    );
  }
}
