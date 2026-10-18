import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';

/// ============================================================================
/// وسائط حماية المسارات (Route Guards Middlewares)
/// ============================================================================

/// حارس المصادقة (AuthGuard): يمنع الدخول للمسارات المحمية لغير المسجلين
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SessionService>()) {
      return const RouteSettings(name: AppRoutes.login);
    }

    final isAuthenticated = SessionService.to.isAuthenticated;
    if (!isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}

/// حارس الضيف (GuestGuard): يمنع المستخدم المسجل من العودة لصفحات تسجيل الدخول
class GuestGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (Get.isRegistered<SessionService>() && SessionService.to.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }
    return null;
  }
}

/// حارس الصلاحيات (PermissionGuardMiddleware): يتحقق من امتلاك الصلاحية المطلوبة
class PermissionGuardMiddleware extends GetMiddleware {
  final String? requiredPermission;
  final List<String>? anyPermissions;
  final String? requiredRole;
  final List<String>? anyRoles;

  PermissionGuardMiddleware({
    this.requiredPermission,
    this.anyPermissions,
    this.requiredRole,
    this.anyRoles,
    int? priority,
  }) : _priority = priority ?? 2;

  final int _priority;

  @override
  int? get priority => _priority;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() || !SessionService.to.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }

    if (!Get.isRegistered<PermissionService>()) {
      return null;
    }

    final perm = PermissionService.to;

    // تجاوز المشرف العام تلقائياً
    if (perm.isSuperAdmin) {
      return null;
    }

    // التحقق من الدور
    if (requiredRole != null && !perm.hasRole(requiredRole!)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    if (anyRoles != null && !perm.hasAnyRole(anyRoles!)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    // التحقق من الصلاحيات الدقيقة
    if (requiredPermission != null && !perm.can(requiredPermission!)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    if (anyPermissions != null && !perm.canAny(anyPermissions!)) {
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    return null;
  }
}
