import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';

class MembershipRoleModel extends MembershipRoleEntity {
  const MembershipRoleModel({
    required super.roleId,
    required super.roleKey,
    required super.name,
  });

  factory MembershipRoleModel.fromJson(Map<String, dynamic> json) =>
      MembershipRoleModel(
        roleId: json['role_id'] is int
            ? json['role_id'] as int
            : int.tryParse(json['role_id']?.toString() ?? '') ?? 0,
        roleKey: json['role_key']?.toString() ?? '',
        name:
            json['role_key_label']?.toString() ??
            json['role_name']?.toString() ??
            '',
      );
}
