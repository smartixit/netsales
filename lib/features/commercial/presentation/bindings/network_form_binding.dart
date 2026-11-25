import 'package:get/get.dart';
import 'package:netsales/features/auth/domain/repositories/auth_repository.dart';
import 'package:netsales/features/auth/domain/usecases/get_directorates_use_case.dart';
import 'package:netsales/features/auth/domain/usecases/get_governorates_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_details_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_form_controller.dart';

class NetworkFormBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GetGovernoratesUseCase>()) {
      Get.lazyPut(() => GetGovernoratesUseCase(Get.find<AuthRepository>()));
    }
    if (!Get.isRegistered<GetDirectoratesUseCase>()) {
      Get.lazyPut(() => GetDirectoratesUseCase(Get.find<AuthRepository>()));
    }
    Get.lazyPut<NetworkFormController>(() => NetworkFormController(
      getGovernorates: Get.find<GetGovernoratesUseCase>(),
      getDirectorates: Get.find<GetDirectoratesUseCase>(),
      createNetwork: Get.find<CreateNetworkUseCase>(),
      updateNetwork: Get.find<UpdateNetworkUseCase>(),
      getNetworkDetails: Get.find<GetNetworkDetailsUseCase>(),
    ));
  }
}
