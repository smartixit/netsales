import 'package:get/get.dart';
import 'package:netsales/core/services/permission_service.dart';
import 'package:netsales/core/services/session_service.dart';
import 'package:netsales/core/services/theme_service.dart';

/// ============================================================================
/// حقن الاعتماديات الأولي للتطبيق (Initial Global Bindings)
/// ============================================================================
/// يضمن تسجيل الخدمات الأساسية في الذاكرة طوال دورة حياة التطبيق (Permanent).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<PermissionService>(PermissionService(), permanent: true);
    Get.put<SessionService>(SessionService(), permanent: true);
  }
}
