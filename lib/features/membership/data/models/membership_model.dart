import 'package:netsales/features/membership/domain/entities/membership_entity.dart';

class MembershipModel extends MembershipEntity {
  const MembershipModel({
    required super.userId,
    required super.fullName,
    required super.phoneNumber,
    required super.roleId,
    required super.roleKey,
    required super.roleLabel,
    required super.status,
    super.profileLogo,
    super.isOwner,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    final role = json['role'] is Map
        ? Map<String, dynamic>.from(json['role'] as Map)
        : <String, dynamic>{};
    return MembershipModel(
      userId: _toInt(json['user_id'] ?? user['user_id']),
      fullName: user['user_full_name']?.toString() ?? 'مستخدم',
      phoneNumber: user['user_phone_number']?.toString() ?? '',
      profileLogo: user['user_profile_logo_url']?.toString() ??
          user['user_profile_logo']?.toString(),
      roleId: _toInt(json['role_id'] ?? role['role_id']),
      roleKey: role['role_key']?.toString() ?? '',
      roleLabel: role['role_key_label']?.toString() ??
          role['role_name']?.toString() ?? 'دور غير محدد',
      status: json['status']?.toString() ?? 'UNKNOWN',
      isOwner: json['is_owner'] == true || json['is_owner'] == 1,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
