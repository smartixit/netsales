import 'package:get/get.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source.dart';
import 'package:netsales/features/billing/data/datasources/billing_remote_data_source_impl.dart';
import 'package:netsales/features/billing/data/repositories/billing_repository_impl.dart';
import 'package:netsales/features/billing/domain/repositories/billing_repository.dart';
import 'package:netsales/features/billing/domain/usecases/billing_use_cases.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_reports_controller.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/finance/presentation/bindings/finance_binding.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/reports/presentation/bindings/operational_reports_binding.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source_impl.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source.dart';
import 'package:netsales/features/workspace/data/repositories/network_workspace_repository_impl.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';

/// ربط تبعيات مساحة عمل مزود الشبكة
class NetworkWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<BillingRemoteDataSource>()) {
      Get.lazyPut<BillingRemoteDataSource>(() => const BillingRemoteDataSourceImpl(), fenix: true);
    }
    if (!Get.isRegistered<BillingRepository>()) {
      Get.lazyPut<BillingRepository>(() => BillingRepositoryImpl(Get.find<BillingRemoteDataSource>()), fenix: true);
    }
    if (!Get.isRegistered<BillingUseCases>()) {
      Get.lazyPut<BillingUseCases>(() => BillingUseCases(Get.find<BillingRepository>()), fenix: true);
    }
    if (!Get.isRegistered<BillingReportsController>()) {
      Get.lazyPut<BillingReportsController>(() => BillingReportsController(
        useCases: Get.find<BillingUseCases>(),
        networkId: () => Get.find<NetworkWorkspaceController>().selectedNetworkId.value,
        networkIdSignal: Get.find<NetworkWorkspaceController>().selectedNetworkId,
      ), fenix: true);
    }
    if (!Get.isRegistered<BillingController>()) {
      Get.lazyPut<BillingController>(() => BillingController(
        useCases: Get.find<BillingUseCases>(),
        networkId: () => Get.find<NetworkWorkspaceController>().selectedNetworkId.value,
        networkIdSignal: Get.find<NetworkWorkspaceController>().selectedNetworkId,
      ), fenix: true);
    }
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
    OperationalReportsBinding().dependencies();
    FinanceBinding().dependencies();
    MembershipBinding(isNetwork: true).dependencies();
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
    Get.lazyPut<NetworkWorkspaceController>(
      () => NetworkWorkspaceController(
        getMyNetworksUseCase: Get.find<GetMyNetworksUseCase>(),
        getOverviewUseCase: Get.find<GetNetworkWorkspaceOverviewUseCase>(),
      ),
    );
  }
}
