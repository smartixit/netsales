import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_trashed_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/restore_network_use_case.dart';
import 'package:netsales/core/di/register_lazy_if_absent.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/commercial/domain/usecases/get_networks_page_use_case.dart';
import 'package:netsales/features/commercial/presentation/controllers/network_directory_controller.dart';
import 'package:netsales/features/billing/presentation/bindings/billing_binding.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/expenses/presentation/bindings/expense_binding.dart';
import 'package:netsales/features/invoices/presentation/bindings/invoice_binding.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/profile/presentation/bindings/profile_binding.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/reports/presentation/bindings/operational_reports_binding.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source_impl.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source.dart';
import 'package:netsales/features/workspace/data/repositories/network_workspace_repository_impl.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_entity_picker_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';

/// ربط تبعيات مساحة عمل مزود الشبكة
class NetworkWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    BillingBinding().dependencies();
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
    registerLazyIfAbsent<NetworkDirectoryController>(
      () => NetworkDirectoryController(
        Get.find<GetNetworksPageUseCase>(),
        Get.find<GetTrashedNetworksUseCase>(),
        Get.find<RestoreNetworkUseCase>(),
      ),
      fenix: true,
    );
    ExpenseBinding().dependencies();
    InvoiceBinding().dependencies();
    WorkspaceEntityPickerBinding().dependencies();
    OperationalReportsBinding().dependencies();
    MembershipBinding().dependencies();
    ProfileBinding().dependencies();
    ProcurementRequestBinding().dependencies();

    if (!Get.isRegistered<NetworkWorkspaceRemoteDataSource>()) {
      Get.lazyPut<NetworkWorkspaceRemoteDataSource>(
        () => const NetworkWorkspaceRemoteDataSourceImpl(),
      );
    }
    if (!Get.isRegistered<NetworkWorkspaceRepository>()) {
      Get.lazyPut<NetworkWorkspaceRepository>(
        () => NetworkWorkspaceRepositoryImpl(
          Get.find<NetworkWorkspaceRemoteDataSource>(),
        ),
      );
    }
    if (!Get.isRegistered<GetNetworkWorkspaceOverviewUseCase>()) {
      Get.lazyPut<GetNetworkWorkspaceOverviewUseCase>(
        () => GetNetworkWorkspaceOverviewUseCase(
          Get.find<NetworkWorkspaceRepository>(),
        ),
      );
    }
    registerLazyIfAbsent<NetworkWorkspaceController>(
      () => NetworkWorkspaceController(
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getOverviewUseCase: Get.find<GetNetworkWorkspaceOverviewUseCase>(),
      ),
    );
  }
}
