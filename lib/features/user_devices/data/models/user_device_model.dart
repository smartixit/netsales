import 'package:netsales/features/user_devices/domain/entities/user_device_entity.dart';

/// نموذج بيانات جهاز المستخدم المقترن.
class UserDeviceModel extends UserDeviceEntity {
  const UserDeviceModel({
    required super.deviceId,
    required super.userId,
    required super.deviceUuid,
    super.deviceName,
    super.deviceType,
    super.deviceTypeLabel,
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
      isPrimary: json['is_primary'] as bool? ?? false,
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      lastUsedAt: json['last_used_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
