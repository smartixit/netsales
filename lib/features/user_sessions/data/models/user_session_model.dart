import 'package:netsales/features/user_sessions/domain/entities/user_session_entity.dart';

/// نموذج بيانات جلسة تسجيل الدخول.
class UserSessionModel extends UserSessionEntity {
  const UserSessionModel({
    required super.sessionId,
    required super.userId,
    super.ipAddress,
    super.userAgent,
    super.deviceUuid,
    super.status,
    super.statusLabel,
    super.isCurrent,
    super.loggedAt,
    super.lastActivityAt,
    super.expiresAt,
    super.revokedAt,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    final rawSessionId = json['session_id'];
    final parsedId = rawSessionId is int
        ? rawSessionId
        : int.tryParse(rawSessionId?.toString() ?? '') ?? 0;

    return UserSessionModel(
      sessionId: parsedId,
      userId: json['user_id'] as int? ?? 0,
      ipAddress: json['ip_address']?.toString(),
      userAgent: json['user_agent']?.toString(),
      deviceUuid: json['device_uuid']?.toString(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      isCurrent: json['is_current'] as bool? ?? false,
      loggedAt: json['logged_at']?.toString(),
      lastActivityAt: json['last_activity_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      revokedAt: json['revoked_at']?.toString(),
    );
  }
}
