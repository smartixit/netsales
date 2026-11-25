import 'package:get/get.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/pos_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';

class PosRelationshipsBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null || id <= 0) return;
    final tag = 'pos-relationships-$id';
    Get.lazyPut<PosCommercialDirectoryController>(
      () => PosCommercialDirectoryController(
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        previewNetworkPosLinkChallengeUseCase: Get.find<PreviewNetworkPosLinkChallengeUseCase>(),
        confirmNetworkPosLinkChallengeUseCase: Get.find<ConfirmNetworkPosLinkChallengeUseCase>(),
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        initialPosId: id,
      ),
      tag: tag,
    );
    Get.lazyPut<BaseCommercialDirectoryController>(
      () => Get.find<PosCommercialDirectoryController>(tag: tag),
      tag: tag,
    );
  }
}
