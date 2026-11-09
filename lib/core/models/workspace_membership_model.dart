import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';

/// نموذج بيانات عضوية مساحة العمل لنظام NetSales (Workspace Membership Model)
///
/// يحمل بيانات سياق العضوية التشغيلية للمستأجر بدقة:
/// - [scope]: النطاق التشغيلي (NETWORK أم POS)
/// - [tenantId]: معرف المستأجر الفعلي (network_id أو pos_id)
/// - [roleKey]: مفتاح الدور التشغيلي (مثل NETWORK_OWNER أو POS_AGENT)
/// - [roleName]: اسم الدور المعرب للعرض
class WorkspaceMembershipModel {
  final RoleScope scope;
  final int tenantId;
  final String roleKey;
  final String roleName;

  const WorkspaceMembershipModel({
    required this.scope,
    required this.tenantId,
    required this.roleKey,
    required this.roleName,
  });

  RoleKey get typedRoleKey => RoleKey.fromWire(roleKey);
  bool get isNetwork => scope == RoleScope.network;
  bool get isPos => scope == RoleScope.pos;

  factory WorkspaceMembershipModel.fromJson(Map<String, dynamic> json) {
    final rawScope = json['scope']?.toString();
    final scope = RoleScope.fromWire(rawScope);

    final rawTenantId = json['tenant_id'];
    final tenantId = rawTenantId is int
        ? rawTenantId
        : int.tryParse(rawTenantId?.toString() ?? '') ?? 0;

    return WorkspaceMembershipModel(
      scope: scope,
      tenantId: tenantId,
      roleKey: json['role_key']?.toString() ?? '',
      roleName: json['role_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scope': scope.wireValue,
      'tenant_id': tenantId,
      'role_key': roleKey,
      'role_name': roleName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceMembershipModel &&
          runtimeType == other.runtimeType &&
          scope == other.scope &&
          tenantId == other.tenantId &&
          roleKey == other.roleKey &&
          roleName == other.roleName;

  @override
  int get hashCode => Object.hash(scope, tenantId, roleKey, roleName);

  @override
  String toString() =>
      'WorkspaceMembershipModel(scope: ${scope.wireValue}, tenantId: $tenantId, roleKey: $roleKey, roleName: $roleName)';
}
