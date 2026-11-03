import 'package:get/get.dart';
import 'package:netsales/features/commercial/presentation/bindings/commercial_binding.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/network_workspace_controller.dart';

/// ربط تبعيات مساحة عمل مزود الشبكة
class NetworkWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    WorkspaceCoordinatorBinding().dependencies();
    CommercialBinding().dependencies();
    Get.lazyPut<NetworkWorkspaceController>(() => NetworkWorkspaceController());
  }
}
