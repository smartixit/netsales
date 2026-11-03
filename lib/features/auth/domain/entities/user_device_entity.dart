/// كيان جهاز المستخدم (User Device Entity)
class UserDeviceEntity {
  final int deviceId;
  final int userId;
  final String deviceUuid;
  final String? deviceName;
  final String? deviceType;
  final String? deviceTypeLabel;
  final String? fcmToken;
  final bool isPrimary;
  final String? status;
  final String? statusLabel;
  final String? lastUsedAt;
  final String? createdAt;
  final String? updatedAt;

  const UserDeviceEntity({
    required this.deviceId,
    required this.userId,
    required this.deviceUuid,
    this.deviceName,
    this.deviceType,
    this.deviceTypeLabel,
    this.fcmToken,
    this.isPrimary = false,
    this.status,
    this.statusLabel,
    this.lastUsedAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'ACTIVE';
}
