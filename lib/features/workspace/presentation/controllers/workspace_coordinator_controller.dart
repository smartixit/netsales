import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/features/auth/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/domain/usecases/set_active_workspace_use_case.dart';

/// المنسق العام لسياق مساحات العمل والتوجيه الآمن
class WorkspaceCoordinatorController extends GetxController {
  final GetActiveWorkspaceUseCase _getActiveWorkspaceUseCase;
  final SetActiveWorkspaceUseCase _setActiveWorkspaceUseCase;

  WorkspaceCoordinatorController({
    required this._getActiveWorkspaceUseCase,
    required this._setActiveWorkspaceUseCase,
  });

  static WorkspaceCoordinatorController get to =>
      Get.find<WorkspaceCoordinatorController>();

  final Rx<WorkspaceContextEntity> activeContext = const WorkspaceContextEntity(
    workspace: AppWorkspace.unsupported,
  ).obs;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshWorkspaceContext();
  }

  /// تحديث ومزامنة سياق مساحة العمل الحالية
  Future<void> refreshWorkspaceContext() async {
    isLoading.value = true;
    try {
      final context = await _getActiveWorkspaceUseCase();
      activeContext.value = context;
    } finally {
      isLoading.value = false;
    }
  }

  /// التبديل المنسق لمساحة العمل مع التوجيه الآمن
  Future<void> switchWorkspace(AppWorkspace workspace) async {
    if (workspace == AppWorkspace.unsupported) {
      await Get.offAllNamed<dynamic>(AppRoutes.unsupportedPlatform);
      return;
    }

    await _setActiveWorkspaceUseCase(workspace);
    await refreshWorkspaceContext();

    if (workspace == AppWorkspace.network) {
      await Get.offAllNamed<dynamic>(AppRoutes.networkWorkspace);
    } else if (workspace == AppWorkspace.pos) {
      await Get.offAllNamed<dynamic>(AppRoutes.posWorkspace);
    }
  }

  /// تسجيل الخروج الآمن وإنهاء الجلسة
  Future<void> logout() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<LogoutUseCase>()) {
        await Get.find<LogoutUseCase>()();
      } else if (Get.isRegistered<SessionService>()) {
        await SessionService.to.terminateSession();
      }
    } catch (_) {
      if (Get.isRegistered<SessionService>()) {
        await SessionService.to.terminateSession();
      }
    } finally {
      if (Get.isRegistered<WorkspaceService>()) {
        await WorkspaceService.to.setActiveWorkspace(AppWorkspace.unsupported);
      }
      isLoading.value = false;
      await Get.offAllNamed<dynamic>(AppRoutes.login);
    }
  }
}
