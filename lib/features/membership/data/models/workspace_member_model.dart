import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';

/// نموذج بيانات عضو مساحة العمل المحول من وإلى استجابة الـ API (Workspace Member Model)
class WorkspaceMemberModel extends WorkspaceMemberEntity {
  const WorkspaceMemberModel({
    required super.userId,
    required super.fullName,
    required super.phoneNumber,
    required super.roleId,
    super.roleKey,
    super.roleLabel,
    super.statusRaw,
    super.statusLabel,
    super.profileLogo,
    super.isOwner,
  });

  factory WorkspaceMemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final role = json['role'] is Map
        ? Map<String, dynamic>.from(json['role'] as Map)
        : <String, dynamic>{};

    final rawStatus = json['status']?.toString() ?? 'UNKNOWN';

    return WorkspaceMemberModel(
      userId: _toInt(json['user_id'] ?? user['user_id']),
      fullName: user['user_full_name']?.toString() ?? 'مستخدم',
      phoneNumber: user['user_phone_number']?.toString() ?? '',
      profileLogo: user['user_profile_logo_url']?.toString() ??
          user['user_profile_logo']?.toString(),
      roleId: _toInt(json['role_id'] ?? role['role_id']),
      roleKey: role['role_key']?.toString(),
      roleLabel: role['role_key_label']?.toString() ??
          role['role_name']?.toString() ??
          'دور غير محدد',
      statusRaw: rawStatus,
      statusLabel: json['status_label']?.toString(),
      isOwner: json['is_owner'] == true || json['is_owner'] == 1,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
