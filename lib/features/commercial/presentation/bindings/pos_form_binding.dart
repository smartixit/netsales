import 'package:get/get.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:netsales/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:netsales/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_pos_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_form_controller.dart';

class PosFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthRemoteDataSource>()) {
      Get.lazyPut<AuthRemoteDataSource>(() => const AuthRemoteDataSourceImpl());
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()));
    }
    if (!Get.isRegistered<GetGovernoratesUseCase>()) {
      Get.lazyPut<GetGovernoratesUseCase>(() => GetGovernoratesUseCase(Get.find<AuthRepository>()));
    }
    if (!Get.isRegistered<GetDirectoratesUseCase>()) {
      Get.lazyPut<GetDirectoratesUseCase>(() => GetDirectoratesUseCase(Get.find<AuthRepository>()));
    }
    Get.lazyPut<PosFormController>(() => PosFormController(
      getGovernorates: Get.find<GetGovernoratesUseCase>(),
      getDirectorates: Get.find<GetDirectoratesUseCase>(),
      createPos: Get.find<CreatePosUseCase>(),
      updatePos: Get.find<UpdatePosUseCase>(),
      getPosDetails: Get.find<GetPosDetailsUseCase>(),
    ));
  }
}
