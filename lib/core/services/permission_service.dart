import 'package:get/get.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';

/// ============================================================================
/// خدمة فحص الصلاحيات والأدوار (Enterprise RBAC & Capability Service)
/// ============================================================================
/// توفر استعلاماً لحظياً بزمن ثابت O(1) عن صلاحيات وأدوار المستخدم الحالي،
/// مع الالتزام بنطاقات التشغيل؛ أدوار المنصة خارج تطبيق Flutter.
class PermissionService extends GetxService {
  PermissionService._();

  static PermissionService instance = PermissionService._();

  static PermissionService get to => Get.isRegistered<PermissionService>()
      ? Get.find<PermissionService>()
      : instance;

  static const Set<RoleKey> _networkRoleKeys = {
    RoleKey.networkOwner,
    RoleKey.networkUser,
    RoleKey.networkAccountant,
  };

  static const Set<RoleKey> _posRoleKeys = {
    RoleKey.posAgent,
    RoleKey.posUser,
    RoleKey.posAccountant,
  };

  final RxSet<String> _permissions = <String>{}.obs;
  final RxString _roleKey = ''.obs;
  final RxSet<String> _workspacePermissions = <String>{}.obs;
  final RxString _workspaceRoleKey = ''.obs;
  bool _workspaceContextBound = false;
  RoleScope _workspaceScope = RoleScope.unknown;
  int _workspaceTenantId = 0;

  bool get hasWorkspaceContext =>
      _workspaceContextBound &&
      (_workspaceScope == RoleScope.network || _workspaceScope == RoleScope.pos) &&
      _workspaceTenantId > 0 &&
      _workspaceRoleKey.value.isNotEmpty;

  /// قائمة الصلاحيات النشطة (للقراءة فقط)
  Set<String> get permissions => _permissions.toSet();

  /// الدور الوظيفي الحالي للمستخدم
  String get currentRole => hasWorkspaceContext ? _workspaceRoleKey.value : '';

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
  /// Reject mismatched or unknown role/scope pairs instead of trusting malformed
  /// membership data to create an operational authorization context.
  void setWorkspaceContext({
    required RoleScope scope,
    required int tenantId,
    required String roleKey,
    required Iterable<String> permissions,
  }) {
    _workspaceContextBound = true;
    _workspaceScope = scope;
    _workspaceTenantId = tenantId;

    final typedRole = RoleKey.fromWire(roleKey);
    final roleMatchesScope = switch (scope) {
      RoleScope.network => _networkRoleKeys.contains(typedRole),
      RoleScope.pos => _posRoleKeys.contains(typedRole),
      RoleScope.platform || RoleScope.unknown => false,
    };
    final isOperationalContext =
        roleMatchesScope && tenantId > 0 && roleKey.trim().isNotEmpty;

    _workspaceRoleKey.value = isOperationalContext ? roleKey : '';
    _workspacePermissions
      ..clear()
      ..addAll(isOperationalContext ? permissions : const <String>[]);
  }

  void clearWorkspaceContext() {
    _workspaceContextBound = false;
    _workspaceScope = RoleScope.unknown;
    _workspaceTenantId = 0;
    _workspaceRoleKey.value = '';
    _workspacePermissions.clear();
  }

  /// فحص امتلاك صلاحية مفردة
  bool can(String permission) {
    return hasWorkspaceContext && _workspaceRoleKey.value.isNotEmpty &&
        _workspacePermissions.contains(permission);
  }

  /// فحص امتلاك أي صلاحية من قائمة معطاة (OR)
  bool canAny(Iterable<String> permissions) {
    return hasWorkspaceContext && _workspaceRoleKey.value.isNotEmpty &&
        permissions.any(_workspacePermissions.contains);
  }

  /// فحص امتلاك كافة الصلاحيات المحددة (AND)
  bool canAll(Iterable<String> permissions) {
    return hasWorkspaceContext && _workspaceRoleKey.value.isNotEmpty &&
        permissions.every(_workspacePermissions.contains);
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
