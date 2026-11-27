import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';

/// نموذج بيانات الدور الوظيفي لعضو مساحة العمل للتحويل من وإلى JSON
class MembershipRoleModel extends MembershipRoleEntity {
  const MembershipRoleModel({
    required super.roleId,
    required super.roleName,
    required super.roleKey,
    required super.scope,
    super.description,
  });

  factory MembershipRoleModel.fromJson(Map<String, dynamic> json) {
    return MembershipRoleModel(
      roleId: json['role_id'] as int? ?? json['id'] as int? ?? 0,
      roleName: json['role_name'] as String? ?? '',
      roleKey: json['role_key'] as String? ?? '',
      scope: json['scope'] as String? ?? '',
      // RoleResource exposes role_desc; keep description as a legacy fallback.
      description: json['role_desc'] as String? ?? json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
      'role_key': roleKey,
      'scope': scope,
      'description': description,
    };
  }
}
