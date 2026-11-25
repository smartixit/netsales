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
  Future<dynamic>? redirect(String? route) {
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
      return Get.offAllNamed(AppRoutes.login);
    }
    if (SessionService.to.isAccessBlocked ||
        SessionService.to.currentUser?.isPlatformUser == true) {
      return  Get.toNamed(AppRoutes.unauthorized);
    }
    if (!SessionService.to.isSessionVerified) {
      return Get.offAllNamed(AppRoutes.initial);
    }

    // الحزام الأمني: منع الوصول لأي صفحة إذا كان تغيير كلمة المرور إلزامياً
    if (SessionService.to.mustChangePassword &&
        route != AppRoutes.resetPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.show(
          title: 'تغيير كلمة المرور إلزامي',
          message: 'يجب تعيين كلمة مرور جديدة لحسابك قبل متابعة استخدام النظام',
          type: SnackType.warning,
        );
      });
      return Get.toNamed(AppRoutes.resetPassword);
    }

    return null;
  }
}

/// حارس الضيف (GuestGuard): يمنع المستخدم المسجل من العودة لصفحات تسجيل الدخول
class GuestGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  Future<dynamic>? redirect(String? route) {
    if (Get.isRegistered<SessionService>() &&
        (SessionService.to.isAccessBlocked ||
            (SessionService.to.isAuthenticated &&
                SessionService.to.currentUser?.isPlatformUser == true))) {
      return Get.toNamed(AppRoutes.unauthorized);
    }

    if (Get.isRegistered<SessionService>() &&
        SessionService.to.isAuthenticated &&
        !SessionService.to.isSessionVerified) {
      return Get.offAllNamed(AppRoutes.initial);
    }

    if (Get.isRegistered<SessionService>() &&
        SessionService.to.isAuthenticated &&
        SessionService.to.isSessionVerified) {
      if (SessionService.to.mustChangePassword) {
        return Get.toNamed(AppRoutes.resetPassword);
      }
      return Get.offAllNamed(AppRoutes.dashboard);
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
  }) : _priority = priority ?? 3;

  final int _priority;

  @override
  int? get priority => _priority;

  @override
  Future<dynamic>? redirect(String? route) {
    if (!Get.isRegistered<SessionService>() ||
        !SessionService.to.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomSnackbar.show(
          title: 'تسجيل الدخول مطلوب',
          message: AppException.sanitizeMessage(
            const UnauthenticatedException('يرجى تسجيل الدخول للمتابعة'),
          ),
          type: SnackType.warning,
        );
      });
      return Get.offAllNamed(AppRoutes.login);
    }

    if (SessionService.to.isAccessBlocked ||
        SessionService.to.currentUser?.isPlatformUser == true) {
      return Get.toNamed(AppRoutes.unauthorized);
    }

    if (!SessionService.to.isSessionVerified) {
      return Get.offAllNamed(AppRoutes.initial);
    }

    if (SessionService.to.mustChangePassword &&
        route != AppRoutes.resetPassword) {
      return Get.toNamed(AppRoutes.resetPassword);
    }

    if (!Get.isRegistered<PermissionService>()) {
      return Get.toNamed(AppRoutes.unauthorized);
    }

    final perm = PermissionService.to;

    // التحقق من الدور
    if (requiredRole != null && !perm.hasRole(requiredRole!)) {
      _notifyDenied('يتطلب هذا المسار دور: $requiredRole');
      return Get.toNamed(AppRoutes.unauthorized);
    }
    if (anyRoles != null && !perm.hasAnyRole(anyRoles!)) {
      _notifyDenied('لا تملك أحد الأدوار المطلوبة للوصول لهذا المسار');
      return Get.toNamed(AppRoutes.unauthorized);
    }

    // التحقق من الصلاحيات الدقيقة
    if (requiredPermission != null && !perm.can(requiredPermission!)) {
      _notifyDenied('يتطلب هذا المسار صلاحية: $requiredPermission');
      return Get.toNamed(AppRoutes.unauthorized);
    }
    if (anyPermissions != null && !perm.canAny(anyPermissions!)) {
      _notifyDenied('لا تملك أي من الصلاحيات المطلوبة للوصول لهذا المسار');
      return Get.toNamed(AppRoutes.unauthorized);
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
