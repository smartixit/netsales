import 'package:get/get.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_commercial_directory_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/toggle_network_pos_link_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/delete_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/revoke_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_link_challenge_status_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/search_network_linkable_pos_use_case.dart';

class NetworkRelationshipsBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null || id <= 0) return;
    final tag = 'network-relationships-$id';
    Get.lazyPut<NetworkCommercialDirectoryController>(
      () => NetworkCommercialDirectoryController(
        getNetworkPosListUseCase: Get.find<GetNetworkPosListUseCase>(),
        toggleNetworkPosLinkStatusUseCase: Get.find<ToggleNetworkPosLinkStatusUseCase>(),
        deleteNetworkPosLinkUseCase: Get.find<DeleteNetworkPosLinkUseCase>(),
        createNetworkPosLinkChallengeUseCase: Get.find<CreateNetworkPosLinkChallengeUseCase>(),
        revokeNetworkPosLinkChallengeUseCase: Get.find<RevokeNetworkPosLinkChallengeUseCase>(),
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getNetworkPosLinkChallengeStatusUseCase: Get.find<GetNetworkPosLinkChallengeStatusUseCase>(),
        searchNetworkLinkablePosUseCase: Get.find<SearchNetworkLinkablePosUseCase>(),
        initialNetworkId: id,
      ),
      tag: tag,
    );
    Get.lazyPut<BaseCommercialDirectoryController>(
      () => Get.find<NetworkCommercialDirectoryController>(tag: tag),
      tag: tag,
    );
  }
}
