/// نموذج الدور الوظيفي (Role Model) مطابق لـ RoleResource في netsales_api
class RoleModel {
  final int roleId;
  final String roleKey;
  final String? roleKeyLabel;
  final String roleName;
  final String? roleDesc;
  final bool isSystem;
  final bool status;

  const RoleModel({
    required this.roleId,
    required this.roleKey,
    this.roleKeyLabel,
    required this.roleName,
    this.roleDesc,
    this.isSystem = false,
    this.status = true,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      roleId: json['role_id'] as int? ?? 0,
      roleKey: json['role_key']?.toString() ?? '',
      roleKeyLabel: json['role_key_label']?.toString(),
      roleName: json['role_name']?.toString() ?? '',
      roleDesc: json['role_desc']?.toString(),
      isSystem: json['is_system'] == true || json['is_system'] == 1,
      status: json['status'] == true || json['status'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_key': roleKey,
      'role_key_label': roleKeyLabel,
      'role_name': roleName,
      'role_desc': roleDesc,
      'is_system': isSystem,
      'status': status,
    };
  }
}
