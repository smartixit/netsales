import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:netsales/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/features/profile/domain/usecases/profile_security_use_cases.dart';
import 'package:netsales/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:netsales/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_2fa_controller.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_edit_form_controller.dart';

/// تسجيل تبعيات وحدة الملف الشخصي عبر الطبقات المعمارية المعتمدة.
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl.new,
      fenix: true,
    );

    registerLazyIfAbsent<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<ProfileRepository>(
      () => ProfileRepositoryImpl(Get.find<ProfileRemoteDataSource>()),
      fenix: true,
    );

    registerLazyIfAbsent<GetProfileUseCase>(
      () => GetProfileUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<UpdateAvatarUseCase>(
      () => UpdateAvatarUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<RequestTwoFactorOtpUseCase>(
      () => RequestTwoFactorOtpUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );
    registerLazyIfAbsent<ToggleTwoFactorUseCase>(
      () => ToggleTwoFactorUseCase(Get.find<ProfileRepository>()),
      fenix: true,
    );

    registerLazyIfAbsent<ProfileController>(
      () => ProfileController(
        getProfileUseCase: Get.find<GetProfileUseCase>(),
        updateProfileUseCase: Get.find<UpdateProfileUseCase>(),
        updateAvatarUseCase: Get.find<UpdateAvatarUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<ProfileEditFormController>(
      () => ProfileEditFormController(
        profileController: Get.find<ProfileController>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<Profile2faController>(
      () => Profile2faController(
        requestTwoFactorOtpUseCase: Get.find<RequestTwoFactorOtpUseCase>(),
        toggleTwoFactorUseCase: Get.find<ToggleTwoFactorUseCase>(),
      ),
      fenix: true,
    );

    registerLazyIfAbsent<ChangePasswordController>(
      () => ChangePasswordController(
        changePasswordUseCase: Get.find<ChangePasswordUseCase>(),
      ),
      fenix: true,
    );
  }
}
