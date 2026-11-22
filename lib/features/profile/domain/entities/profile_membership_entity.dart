import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/role_key.dart';
import 'package:netsales/core/enums/role_scope.dart';

/// One operational tenant membership belonging to the authenticated user.
class ProfileMembershipEntity extends Equatable {
  const ProfileMembershipEntity({
    required this.scope,
    required this.tenantId,
    required this.roleKey,
    required this.roleName,
  });

  final RoleScope scope;
  final int tenantId;
  final RoleKey roleKey;
  final String roleName;

  bool get isNetwork => scope == RoleScope.network;

  bool get isPos => scope == RoleScope.pos;

  String get scopeLabel => switch (scope) {
    RoleScope.network => 'مساحة شبكة',
    RoleScope.pos => 'مساحة نقطة بيع',
    _ => 'مساحة عمل',
  };

  @override
  List<Object?> get props => [scope, tenantId, roleKey, roleName];
}
