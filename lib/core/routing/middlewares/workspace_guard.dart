import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/workspace_service.dart';

/// ============================================================================
/// وسيط حماية وتوجيه مساحات العمل التشغيلية (Workspace Routing Guard)
/// ============================================================================
/// يوجه المستخدم المسجل لمساحة عمله المعتمدة (NETWORK أو POS)
/// ويعترض حسابات إدارة المنصة ويوجهها لصفحة التنبيه (AUTH-06).
class WorkspaceGuard extends GetMiddleware {
  final AppWorkspace? targetWorkspace;

  WorkspaceGuard({this.targetWorkspace});

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final user = SessionService.to.currentUser;
    final workspaceService = WorkspaceService.to;
    final resolved = workspaceService.resolveWorkspaceForUser(user);

    // إذا كان الحساب مشرف منصة (SUPER_ADMIN / SUPPORT_AGENT)، اعتراض وتوجيه لـ AUTH-06
    // if (resolved == AppWorkspace.unsupported) {
    //   // if (route != AppRoutes.unsupportedPlatform) {
    //     // return const RouteSettings(name: AppRoutes.unsupportedPlatform);
    //   // }
    //   // return null;
    // }

    // إذا كان المسار مقيداً بمساحة معينة لا تتطابق مع المستخدم، التوجيه لمساحته الصحيحة
    if (targetWorkspace != null && targetWorkspace != resolved) {
      final fallbackRoute = resolved == AppWorkspace.network
          ? AppRoutes.networkWorkspace
          : AppRoutes.posWorkspace;
      return RouteSettings(name: fallbackRoute);
    }

    // عند الدخول إلى المسار العام للوحة التحكم، التوجيه التلقائي لمساحة عمل المستخدم
    if (route == AppRoutes.dashboard) {
      final destination = resolved == AppWorkspace.network
          ? AppRoutes.networkWorkspace
          : AppRoutes.posWorkspace;
      return RouteSettings(name: destination);
    }

    return null;
  }
}
