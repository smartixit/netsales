import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:netsales/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:netsales/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:netsales/features/profile/domain/repositories/profile_repository.dart';
import 'package:netsales/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    registerLazyIfAbsent<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(const AuthRemoteDataSourceImpl()),
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
    registerLazyIfAbsent<ProfileController>(
      () => ProfileController(getProfileUseCase: Get.find<GetProfileUseCase>()),
      fenix: true,
    );
  }
}
