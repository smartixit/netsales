import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';

/// كيان الدور الوظيفي المتاح لإسناده لعضو مساحة العمل (Membership Role Entity)
class MembershipRoleEntity {
  final int roleId;
  final String roleName;
  final String roleKey;
  final String scope;
  final String? description;

  const MembershipRoleEntity({
    required this.roleId,
    required this.roleName,
    required this.roleKey,
    required this.scope,
    this.description,
  });

  RoleKey get typedRoleKey => RoleKey.fromWire(roleKey);

  RoleScope get typedScope => RoleScope.fromWire(scope);
}
