import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_pos_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_pos_networks_list_use_case.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/finance/domain/usecases/pos_wallet_use_cases.dart';
import 'package:netsales/features/finance/presentation/bindings/finance_binding.dart';
import 'package:netsales/features/invoices/presentation/bindings/invoice_binding.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/reports/presentation/bindings/operational_reports_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

class PosWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
    OperationalReportsBinding().dependencies();
    FinanceBinding().dependencies();
    InvoiceBinding().dependencies();
    MembershipBinding(isNetwork: false).dependencies();
    ProcurementRequestBinding().dependencies();
    Get.lazyPut<PosWorkspaceController>(
      () => PosWorkspaceController(
        getMyPosUseCase: Get.find<GetMyPosUseCase>(),
        getPosNetworksListUseCase: Get.find<GetPosNetworksListUseCase>(),
        getPosWalletByNetworkAndPosUseCase:
            Get.find<GetPosWalletByNetworkAndPosUseCase>(),
      ),
    );
  }
}
