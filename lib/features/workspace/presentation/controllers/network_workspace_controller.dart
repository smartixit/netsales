import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/services/workspace_service.dart';

/// وحدة التحكم الخاصة بهيكل مساحة عمل مزود الشبكة (Network Workspace)
class NetworkWorkspaceController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // التحقق من تعيين مساحة عمل الشبكة
    if (WorkspaceService.to.activeWorkspace != AppWorkspace.network) {
      WorkspaceService.to.setActiveWorkspace(AppWorkspace.network);
    }
  }

  void onNavItemSelected(int index) {
    selectedNavIndex.value = index;
  }
}

