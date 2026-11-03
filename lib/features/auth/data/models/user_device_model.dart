import 'package:netsales/features/auth/domain/entities/user_device_entity.dart';

/// نموذج بيانات جهاز المستخدم (User Device Model)
class UserDeviceModel extends UserDeviceEntity {
  const UserDeviceModel({
    required super.deviceId,
    required super.userId,
    required super.deviceUuid,
    super.deviceName,
    super.deviceType,
    super.deviceTypeLabel,
    super.fcmToken,
    super.isPrimary,
    super.status,
    super.statusLabel,
    super.lastUsedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) {
    return UserDeviceModel(
      deviceId: json['device_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      deviceUuid: json['device_uuid']?.toString() ?? '',
      deviceName: json['device_name']?.toString(),
      deviceType: json['device_type']?.toString(),
      deviceTypeLabel: json['device_type_label']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      isPrimary: json['is_primary'] as bool? ?? false,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      lastUsedAt: json['last_used_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'user_id': userId,
      'device_uuid': deviceUuid,
      'device_name': deviceName,
      'device_type': deviceType,
      'device_type_label': deviceTypeLabel,
      'fcm_token': fcmToken,
      'is_primary': isPrimary,
      'status': status,
      'status_label': statusLabel,
      'last_used_at': lastUsedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

