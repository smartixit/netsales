import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/auth/domain/usecases/logout_use_case.dart';
import 'package:netsales/features/workspace/domain/entities/workspace_context_entity.dart';
import 'package:netsales/features/workspace/domain/usecases/get_active_workspace_use_case.dart';
import 'package:netsales/features/workspace/domain/usecases/set_active_workspace_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';

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
    workspace: AppWorkspace.network,
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

  /// التحقق من صلاحية المستخدم للتبديل بين مساحتي عمل (شبكة ونقطة بيع)
  bool get canSwitchWorkspace {
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;
    return WorkspaceService.to.canSwitchWorkspace(user);
  }

  /// نص التلميح للتنقل بين المساحات
  String get switchWorkspaceTooltip {
    final isNetwork = activeContext.value.workspace == AppWorkspace.network;
    return isNetwork
        ? 'التبديل إلى مساحة عمل نقطة البيع'
        : 'التبديل إلى مساحة عمل مزود الشبكة';
  }

  /// حل كائن العرض الدلالي للدور الوظيفي لمساحة العمل
  EnumPresentation resolveRolePresentation(AppWorkspace workspace) {
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;
    final targetScope = workspace == AppWorkspace.network
        ? RoleScope.network
        : RoleScope.pos;
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (m) => m.scope == targetScope,
    );
    final rawRoleKey =
        membership?.roleKey ?? user?.role?.roleKey ?? user?.generalRoleKey;
    final serverLabel =
        membership?.roleName ??
        user?.role?.roleName ??
        user?.role?.roleKeyLabel;
    final typedRoleKey = RoleKey.fromWire(rawRoleKey);
    final presentation = EnumPresentationRegistry.resolveRoleKey(
      typedRoleKey,
      serverLabel: serverLabel,
    );
    if (presentation.isKnown) {
      return presentation;
    }
    return EnumPresentationRegistry.resolveRoleScope(
      targetScope,
      serverLabel: serverLabel,
    );
  }

  String get currentUserName {
    final name = SessionService.to.currentUser?.userFullName.trim() ?? '';
    return name.isEmpty ? 'المستخدم' : name;
  }

  String get currentUserInitials =>
      TextFormatter.avatarInitials(currentUserName, maxChars: 2);

  String? get currentUserPhoneNumber =>
      SessionService.to.currentUser?.userPhoneNumber;

  String? get currentUserProfileLogo =>
      SessionService.to.currentUser?.userProfileLogo;

  void openSecuritySettings() => Get.toNamed<void>(AppRoutes.securitySettings);

  void openActiveSessions() => Get.toNamed<void>(AppRoutes.activeSessions);

  void toggleTheme() => ThemeService.to.toggleTheme();

  /// التبديل التلقائي إلى المساحة المقابلة
  Future<void> toggleWorkspace() async {
    final isNetwork = activeContext.value.workspace == AppWorkspace.network;
    final target = isNetwork ? AppWorkspace.pos : AppWorkspace.network;
    await switchWorkspace(target);
  }

  /// التبديل المنسق لمساحة العمل مع التوجيه الآمن
  Future<void> switchWorkspace(AppWorkspace workspace) async {
    // if (workspace == AppWorkspace.unsupported) {
    //   await Get.offAllNamed<dynamic>(AppRoutes.unsupportedPlatform);
    //   return;
    // }

    await _setActiveWorkspaceUseCase(workspace);
    await refreshWorkspaceContext();

    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      Get.back<void>();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

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
      await CustomAnimationOverlay.showLoading();

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
        await WorkspaceService.to.setActiveWorkspace(AppWorkspace.network);
      }
      isLoading.value = false;
      if (CustomAnimationOverlay.isShowing) {
        await CustomAnimationOverlay.hide();
      }
      await Get.offAllNamed<dynamic>(AppRoutes.login);
    }
  }
}
