import 'package:get/get.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/confirm_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/preview_network_pos_link_challenge_use_case.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/invoices/domain/usecases/get_pos_invoices_use_case.dart';
import 'package:netsales/features/invoices/presentation/bindings/invoice_binding.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/reports/presentation/bindings/operational_reports_binding.dart';
import 'package:netsales/features/requests/domain/usecases/get_requests_use_case.dart';
import 'package:netsales/features/requests/presentation/bindings/pos_procurement_orders_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_entity_picker_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

class PosWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
    WorkspaceEntityPickerBinding().dependencies();
    OperationalReportsBinding().dependencies();
    InvoiceBinding().dependencies();
    MembershipBinding().dependencies();
    PosProcurementOrdersBinding().dependencies();

    registerLazyIfAbsent<PosWorkspaceController>(
      () => PosWorkspaceController(
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        getPosInvoicesUseCase: Get.find<GetPosInvoicesUseCase>(),
        getRequestsUseCase: Get.find<GetRequestsUseCase>(),
        previewNetworkPosLinkChallengeUseCase:
            Get.find<PreviewNetworkPosLinkChallengeUseCase>(),
        confirmNetworkPosLinkChallengeUseCase:
            Get.find<ConfirmNetworkPosLinkChallengeUseCase>(),
      ),
    );
  }
}
