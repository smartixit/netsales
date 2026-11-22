import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/theme_service.dart';
import 'package:netsales/core/services/workspace_service.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/auth/domain/usecases/logout_use_case.dart';
import 'package:netsales/widgets/dialogs/custom_animation_overlay.dart';

/// Coordinates workspace navigation and shared session actions.
///
/// WorkspaceService is the single source of truth for the selected workspace.
class WorkspaceCoordinatorController extends GetxController {
  static WorkspaceCoordinatorController get to =>
      Get.find<WorkspaceCoordinatorController>();

  final RxBool isLoading = false.obs;

  bool get canSwitchWorkspace {
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;
    return WorkspaceService.to.canSwitchWorkspace(user);
  }

  String get switchWorkspaceTooltip =>
      WorkspaceService.to.activeWorkspace == AppWorkspace.network
      ? 'التبديل إلى مساحة عمل نقطة البيع'
      : 'التبديل إلى مساحة عمل مزود الشبكة';

  EnumPresentation resolveRolePresentation(AppWorkspace workspace) {
    final user = Get.isRegistered<SessionService>()
        ? SessionService.to.currentUser
        : null;
    final targetScope = workspace == AppWorkspace.network
        ? RoleScope.network
        : RoleScope.pos;
    final membership = user?.workspaceMemberships.firstWhereOrNull(
      (item) => item.scope == targetScope,
    );
    final rawRoleKey =
        membership?.roleKey ?? user?.role?.roleKey ?? user?.generalRoleKey;
    final serverLabel =
        membership?.roleName ??
        user?.role?.roleName ??
        user?.role?.roleKeyLabel;

    final presentation = EnumPresentationRegistry.resolveRoleKey(
      RoleKey.fromWire(rawRoleKey),
      serverLabel: serverLabel,
    );
    if (presentation.isKnown) return presentation;

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
      TextFormatter.avatarInitials(currentUserName);

  String? get currentUserPhoneNumber =>
      SessionService.to.currentUser?.userPhoneNumber;

  String? get currentUserProfileLogo =>
      SessionService.to.currentUser?.userProfileLogo;

  void openSecuritySettings() => Get.toNamed<void>(AppRoutes.securitySettings);

  void openActiveSessions() => Get.toNamed<void>(AppRoutes.activeSessions);

  void toggleTheme() => ThemeService.to.toggleTheme();

  Future<void> toggleWorkspace() async {
    final target = WorkspaceService.to.activeWorkspace == AppWorkspace.network
        ? AppWorkspace.pos
        : AppWorkspace.network;
    await switchWorkspace(target);
  }

  Future<void> switchWorkspace(AppWorkspace workspace) async {
    if (workspace == WorkspaceService.to.activeWorkspace) return;

    isLoading.value = true;
    if (Get.isBottomSheetOpen == true || Get.isDialogOpen == true) {
      Get.back<void>();
    }
    try {
      await WorkspaceService.to.setActiveWorkspace(workspace);


      final route = workspace == AppWorkspace.network
          ? AppRoutes.networkWorkspace
          : AppRoutes.posWorkspace;
      await Get.offAllNamed<void>(route);
    } finally {
      isLoading.value = false;
    }
  }

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
      await Get.offAllNamed<void>(AppRoutes.login);
    }
  }
}
