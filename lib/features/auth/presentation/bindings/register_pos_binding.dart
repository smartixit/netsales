import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/register_pos_use_case.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';

/// تسجيل وحقن اعتماديات شاشة تسجيل نقطة بيع / وكيل جديد
class RegisterPosBinding extends Bindings {
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

    Get.lazyPut<GetGovernoratesUseCase>(
      () => GetGovernoratesUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<GetDirectoratesUseCase>(
      () => GetDirectoratesUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<RegisterPosUseCase>(
      () => RegisterPosUseCase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<RegisterPosController>(
      () => RegisterPosController(
        getGovernoratesUseCase: Get.find<GetGovernoratesUseCase>(),
        getDirectoratesUseCase: Get.find<GetDirectoratesUseCase>(),
        registerPosUseCase: Get.find<RegisterPosUseCase>(),
      ),
    );
  }
}
