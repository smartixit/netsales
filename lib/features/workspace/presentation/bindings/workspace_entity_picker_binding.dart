import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_entity_picker_controller.dart';

class WorkspaceEntityPickerBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<WorkspaceEntityPickerController>()) return;

    Get.lazyPut<WorkspaceEntityPickerController>(
      () => WorkspaceEntityPickerController(
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
      ),
      fenix: true,
    );
  }
}
