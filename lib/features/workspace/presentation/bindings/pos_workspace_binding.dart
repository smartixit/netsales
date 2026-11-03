import 'package:get/get.dart';
import 'package:netsales/features/workspace/presentation/bindings/workspace_coordinator_binding.dart';
import 'package:netsales/features/workspace/presentation/controllers/pos_workspace_controller.dart';

/// ربط تبعيات مساحة عمل نقطة البيع
class PosWorkspaceBinding extends Bindings {
  @override
  void dependencies() {
    WorkspaceCoordinatorBinding().dependencies();
    Get.lazyPut<PosWorkspaceController>(() => PosWorkspaceController());
  }
}
