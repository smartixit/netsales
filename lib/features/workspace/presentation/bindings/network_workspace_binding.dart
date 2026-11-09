import 'package:get/get.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/commercial/domain/usecases/get_my_networks_use_case.dart';
import 'package:netsales/features/requests/presentation/bindings/procurement_request_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source.dart';
import 'package:netsales/features/workspace/data/datasources/network_workspace_remote_data_source_impl.dart';
import 'package:netsales/features/workspace/data/repositories/network_workspace_repository_impl.dart';
import 'package:netsales/features/workspace/domain/repositories/network_workspace_repository.dart';
import 'package:netsales/features/workspace/domain/usecases/get_network_workspace_overview_use_case.dart';
import 'package:netsales/features/membership/presentation/bindings/membership_binding.dart';

/// ربط تبعيات مساحة عمل مزود الشبكة
class NetworkWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
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
