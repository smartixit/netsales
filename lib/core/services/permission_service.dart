import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';

/// ============================================================================
/// خدمة فحص الصلاحيات والأدوار (Enterprise RBAC & Capability Service)
/// ============================================================================
/// توفر استعلاماً لحظياً بزمن ثابت O(1) عن صلاحيات وأدوار المستخدم الحالي،
/// مع دعم تجاوز المشرف العام (Super Admin Bypass) تلقائياً.
class PermissionService extends GetxService {
  static PermissionService get to => Get.find<PermissionService>();

  final RxSet<String> _permissions = <String>{}.obs;
  final RxString _roleKey = ''.obs;

  /// قائمة الصلاحيات النشطة (للقراءة فقط)
  Set<String> get permissions => _permissions.toSet();

  /// الدور الوظيفي الحالي للمستخدم
  String get currentRole => _roleKey.value;

  /// هل المستخدم هو المشرف العام على النظام
  bool get isSuperAdmin => _roleKey.value == AppRoles.superAdmin;

  /// تهيئة أو تحديث الصلاحيات والدور
  void updateAccess({
    required String roleKey,
    required Iterable<String> permissions,
  }) {
    _roleKey.value = roleKey;
    _permissions
      ..clear()
      ..addAll(permissions);
  }

  /// فحص امتلاك صلاحية مفردة
  bool can(String permission) {
    if (isSuperAdmin) return true;
    return _permissions.contains(permission);
  }

  /// فحص امتلاك أي صلاحية من قائمة معطاة (OR)
  bool canAny(Iterable<String> permissions) {
    if (isSuperAdmin) return true;
    return permissions.any(_permissions.contains);
  }

  /// فحص امتلاك كافة الصلاحيات المحددة (AND)
  bool canAll(Iterable<String> permissions) {
    if (isSuperAdmin) return true;
    return permissions.every(_permissions.contains);
  }

  /// التحقق من تطابق الدور الوظيفي
  bool hasRole(String roleKey) {
    return _roleKey.value == roleKey;
  }

  /// التحقق مما إذا كان المستخدم يحمل أي دور من قائمة أدوار
  bool hasAnyRole(Iterable<String> roles) {
    return roles.contains(_roleKey.value);
  }

  /// مسح كافة الصلاحيات والأدوار (عند تسجيل الخروج)
  void clear() {
    _roleKey.value = '';
    _permissions.clear();
  }
}
