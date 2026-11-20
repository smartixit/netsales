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
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    if (SessionService.to.isAccessBlocked) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    if (!SessionService.to.isSessionVerified) {
      return const RouteSettings(name: AppRoutes.initial);
    }

    final user = SessionService.to.currentUser;
    if (user == null) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    final AppWorkspace resolved;
    try {
      resolved = WorkspaceService.to.resolveWorkspaceForUser(user);
    } on StateError {
      // An authenticated session without a supported operational role is
      // invalid. Never infer a workspace from partial or unknown role data.
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    if (targetWorkspace != null && targetWorkspace != resolved) {
      return RouteSettings(
        name: resolved == AppWorkspace.network
            ? AppRoutes.networkWorkspace
            : AppRoutes.posWorkspace,
      );
    }

    if (route == AppRoutes.dashboard) {
      return RouteSettings(
        name: resolved == AppWorkspace.network
            ? AppRoutes.networkWorkspace
            : AppRoutes.posWorkspace,
      );
    }

    return null;
  }
}
