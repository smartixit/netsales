import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';

/// وحدة التحكم الخاصة بهيكل مساحة عمل نقطة البيع (POS Workspace)
class PosWorkspaceController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // التحقق من تعيين مساحة عمل نقطة البيع
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.pos) {
      WorkspaceService.to.setActiveWorkspace(AppWorkspace.pos);
    }
  }

  void onNavItemSelected(int index) {
    selectedNavIndex.value = index;
  }
}

