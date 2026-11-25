import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';

/// UX routing guard for supported operational workspaces.
/// Authorization remains exclusively enforced by the Laravel API.
class WorkspaceGuard extends GetMiddleware {
  WorkspaceGuard({this.targetWorkspace});

  final AppWorkspace? targetWorkspace;

  @override
  int? get priority => 2;

  @override
  Future<dynamic>? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      return Get.offAllNamed(AppRoutes.login);
    }
    if (SessionService.to.isAccessBlocked) {
      return Get.toNamed(AppRoutes.unauthorized);
    }
    if (!SessionService.to.isSessionVerified) {
      return Get.offAllNamed(AppRoutes.initial);
    }

    final user = SessionService.to.currentUser;
    if (user == null) {
      return Get.toNamed(AppRoutes.unauthorized);
    }

    final AppWorkspace resolved;
    try {
      resolved = WorkspaceService.to.resolveWorkspaceForUser(user);
    } on StateError {
      // An authenticated session without a supported operational role is
      // invalid. Never infer a workspace from partial or unknown role data.
      return Get.toNamed(AppRoutes.unauthorized);
    }

    if (targetWorkspace != null && targetWorkspace != resolved) {
      return Get.offAllNamed(
        resolved == AppWorkspace.network
            ? AppRoutes.networkWorkspace
            : AppRoutes.posWorkspace,
      );
    }

    if (route == AppRoutes.dashboard) {
      return Get.offAllNamed(
        resolved == AppWorkspace.network
            ? AppRoutes.networkWorkspace
            : AppRoutes.posWorkspace,
      );
    }

    return null;
  }
}
