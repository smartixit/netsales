import 'package:get/get.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_pos_lifecycle_controller.dart';
import 'package:netsales/features/commercial/domain/usecases/activate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/create_network_pos_agreement_draft_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_agreements_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_network_pos_events_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/terminate_network_pos_agreement_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_network_pos_links_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_pos_link_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/update_network_pos_agreement_draft_use_case.dart';

class NetworkPosLifecycleBinding extends Bindings {
  @override
  void dependencies() {
    final id = int.tryParse(Get.parameters['id'] ?? '');
    if (id == null || id <= 0) return;
    Get.lazyPut<NetworkPosLifecycleController>(
      () => NetworkPosLifecycleController(
        networkPosId: id,
        entityId: (Get.arguments is Map ? (Get.arguments['entity_id'] as num?)?.toInt() : null) ?? 0,
        isNetworkScope: Get.arguments is Map ? Get.arguments['is_network'] == true : true,
        getTrashedLinksUseCase: Get.find<GetTrashedNetworkPosLinksUseCase>(),
        restoreLinkUseCase: Get.find<RestoreNetworkPosLinkUseCase>(),
        getAgreementsUseCase: Get.find<GetNetworkPosAgreementsUseCase>(),
        getEventsUseCase: Get.find<GetNetworkPosEventsUseCase>(),
        createDraftUseCase: Get.find<CreateNetworkPosAgreementDraftUseCase>(),
        updateDraftUseCase: Get.find<UpdateNetworkPosAgreementDraftUseCase>(),
        activateUseCase: Get.find<ActivateNetworkPosAgreementUseCase>(),
        terminateUseCase: Get.find<TerminateNetworkPosAgreementUseCase>(),
      ),
      tag: 'network-pos-lifecycle-$id',
    );
  }
}
