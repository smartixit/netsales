import 'package:get/get.dart';
import 'package:netsales/core/constants/app_permissions.dart';
import 'package:netsales/core/enums/role_scope.dart';

/// ============================================================================
/// خدمة فحص الصلاحيات والأدوار (Enterprise RBAC & Capability Service)
/// ============================================================================
/// توفر استعلاماً لحظياً بزمن ثابت O(1) عن صلاحيات وأدوار المستخدم الحالي،
/// مع دعم تجاوز المشرف العام (Super Admin Bypass) تلقائياً.
class PermissionService extends GetxService {
  PermissionService._();

  static PermissionService instance = PermissionService._();

  static PermissionService get to => Get.isRegistered<PermissionService>()
      ? Get.find<PermissionService>()
      : instance;

  final RxSet<String> _permissions = <String>{}.obs;
  final RxString _roleKey = ''.obs;
  final RxSet<String> _workspacePermissions = <String>{}.obs;
  final RxString _workspaceRoleKey = ''.obs;
  bool _workspaceContextBound = false;

  /// قائمة الصلاحيات النشطة (للقراءة فقط)
  Set<String> get permissions => _permissions.toSet();

  /// الدور الوظيفي الحالي للمستخدم
  String get currentRole => _workspaceContextBound
      ? _workspaceRoleKey.value
      : _roleKey.value;

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
    clearWorkspaceContext();
  }

  /// Bind UI capabilities to one exact active tenant membership.
  /// An absent membership is a deny-all context, never a global union fallback.
  void setWorkspaceContext({
    required RoleScope scope,
    required int tenantId,
    required String roleKey,
    required Iterable<String> permissions,
  }) {
    _workspaceContextBound = true;
    _workspaceRoleKey.value = roleKey;
    _workspacePermissions
      ..clear()
      ..addAll(tenantId > 0 ? permissions : const <String>[]);
  }

  void clearWorkspaceContext() {
    _workspaceContextBound = false;
    _workspaceRoleKey.value = '';
    _workspacePermissions.clear();
  }

  /// فحص امتلاك صلاحية مفردة
  bool can(String permission) {
    if (isSuperAdmin) return true;
    return _workspaceContextBound
        ? _workspacePermissions.contains(permission)
        : _permissions.contains(permission);
  }

  /// فحص امتلاك أي صلاحية من قائمة معطاة (OR)
  bool canAny(Iterable<String> permissions) {
    if (isSuperAdmin) return true;
    final source = _workspaceContextBound ? _workspacePermissions : _permissions;
    return permissions.any(source.contains);
  }

  /// فحص امتلاك كافة الصلاحيات المحددة (AND)
  bool canAll(Iterable<String> permissions) {
    if (isSuperAdmin) return true;
    final source = _workspaceContextBound ? _workspacePermissions : _permissions;
    return permissions.every(source.contains);
  }

  /// التحقق من تطابق الدور الوظيفي
  bool hasRole(String roleKey) {
    return currentRole == roleKey;
  }

  /// التحقق مما إذا كان المستخدم يحمل أي دور من قائمة أدوار
  bool hasAnyRole(Iterable<String> roles) {
    return roles.contains(currentRole);
  }

  /// مسح كافة الصلاحيات والأدوار (عند تسجيل الخروج)
  void clear() {
    _roleKey.value = '';
    _permissions.clear();
    clearWorkspaceContext();
  }
}
