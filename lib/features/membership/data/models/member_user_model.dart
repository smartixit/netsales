import 'package:netsales/features/membership/domain/entities/member_user_entity.dart';

/// نموذج بيانات المستخدم الأساسي لعضو مساحة العمل للتحويل من وإلى JSON
class MemberUserModel extends MemberUserEntity {
  const MemberUserModel({
    required super.userId,
    required super.userUuid,
    required super.fullName,
    required super.phoneNumber,
    super.email,
    super.statusRaw,
    super.statusLabel,
    super.profilePictureUrl,
  });

  factory MemberUserModel.fromJson(Map<String, dynamic> json) {
    return MemberUserModel(
      userId: json['user_id'] as int? ?? 0,
      userUuid: json['user_uuid'] as String? ?? '',
      fullName:
          json['user_full_name'] as String? ??
          json['full_name'] as String? ??
          '',
      phoneNumber:
          json['user_phone_number'] as String? ??
          json['phone_number'] as String? ??
          '',
      email: json['user_email'] as String? ?? json['email'] as String?,
      statusRaw: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      profilePictureUrl:
          json['user_profile_picture'] as String? ??
          json['user_profile_logo_url'] as String? ??
          json['profile_picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_uuid': userUuid,
      'user_full_name': fullName,
      'user_phone_number': phoneNumber,
      'user_email': email,
      'status': statusRaw,
      'status_label': statusLabel,
      'user_profile_picture': profilePictureUrl,
    };
  }
}
