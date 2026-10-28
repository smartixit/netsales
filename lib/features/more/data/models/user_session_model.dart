import 'package:netsales/core/services/device_service.dart';
import 'package:netsales/features/more/domain/entities/user_session_entity.dart';

/// ============================================================================
/// نموذج بيانات الجلسة النشطة (UserSessionModel)
/// ============================================================================
class UserSessionModel extends UserSessionEntity {
  const UserSessionModel({
    required super.sessionId,
    required super.userId,
    required super.ipAddress,
    required super.userAgent,
    required super.deviceUuid,
    super.loggedAt,
    super.lastActivityAt,
    super.expiresAt,
    super.isCurrentSession,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final devUuid = json['device_uuid']?.toString() ?? '';
    final currentDeviceUuid = DeviceService.to.deviceUuid;
    final isCurrent = currentDeviceUuid.isNotEmpty && devUuid == currentDeviceUuid;

    return UserSessionModel(
      sessionId: (json['session_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      ipAddress: json['ip_address']?.toString() ?? '',
      userAgent: json['user_agent']?.toString() ?? 'جهاز غير معروف',
      deviceUuid: devUuid,
      loggedAt: parseDate(json['logged_at']),
      lastActivityAt: parseDate(json['last_activity_at']),
      expiresAt: parseDate(json['expires_at']),
      isCurrentSession: isCurrent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'device_uuid': deviceUuid,
      'logged_at': loggedAt?.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
