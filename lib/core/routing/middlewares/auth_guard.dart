import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// وسائط حماية المسارات (Route Guards Middlewares)
/// ============================================================================

/// حارس المصادقة (AuthGuard): يمنع الدخول للمسارات المحمية لغير المسجلين
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.show(
          title: 'تسجيل الدخول مطلوب',
          message: AppException.sanitizeMessage(
            const UnauthenticatedException(
              'يرجى تسجيل الدخول للوصول إلى هذه الصفحة',
            ),
          ),
          type: SnackType.warning,
        );
      });
      return const RouteSettings(name: AppRoutes.login);
    }

    // الحزام الأمني: منع الوصول لأي صفحة إذا كان تغيير كلمة المرور إلزامياً
    if (SessionService.to.mustChangePassword && route != AppRoutes.resetPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.show(
          title: 'تغيير كلمة المرور إلزامي',
          message: 'يجب تعيين كلمة مرور جديدة لحسابك قبل متابعة استخدام النظام',
          type: SnackType.warning,
        );
      });
      return const RouteSettings(name: AppRoutes.resetPassword);
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
      if (SessionService.to.mustChangePassword) {
        return const RouteSettings(name: AppRoutes.resetPassword);
      }
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
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.show(
          title: 'تسجيل الدخول مطلوب',
          message: AppException.sanitizeMessage(
            const UnauthenticatedException(
              'يرجى تسجيل الدخول للمتابعة',
            ),
          ),
          type: SnackType.warning,
        );
      });
      return const RouteSettings(name: AppRoutes.login);
    }

    if (SessionService.to.mustChangePassword && route != AppRoutes.resetPassword) {
      return const RouteSettings(name: AppRoutes.resetPassword);
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
      _notifyDenied('يتطلب هذا المسار دور: $requiredRole');
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    if (anyRoles != null && !perm.hasAnyRole(anyRoles!)) {
      _notifyDenied('لا تملك أحد الأدوار المطلوبة للوصول لهذا المسار');
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    // التحقق من الصلاحيات الدقيقة
    if (requiredPermission != null && !perm.can(requiredPermission!)) {
      _notifyDenied('يتطلب هذا المسار صلاحية: $requiredPermission');
      return const RouteSettings(name: AppRoutes.unauthorized);
    }
    if (anyPermissions != null && !perm.canAny(anyPermissions!)) {
      _notifyDenied('لا تملك أي من الصلاحيات المطلوبة للوصول لهذا المسار');
      return const RouteSettings(name: AppRoutes.unauthorized);
    }

    return null;
  }

  void _notifyDenied([String? reason]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomSnackbar.show(
        title: 'صلاحية غير متوفرة',
        message: AppException.sanitizeMessage(
          PermissionDeniedException(
            reason ?? 'ليس لديك الصلاحية الكافية للوصول إلى هذا المسار',
          ),
        ),
        type: SnackType.warning,
      );
    });
  }
}
