/// نموذج جلسة المستخدم (User Session Model) مطابق لـ UserSessionResource في netsales_api
class UserSessionModel {
  final String sessionId;
  final int userId;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceUuid;
  final String? loggedAt;
  final String? lastActivityAt;
  final String? expiresAt;

  const UserSessionModel({
    required this.sessionId,
    required this.userId,
    this.ipAddress,
    this.userAgent,
    this.deviceUuid,
    this.loggedAt,
    this.lastActivityAt,
    this.expiresAt,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      sessionId: json['session_id']?.toString() ?? '',
      userId: json['user_id'] as int? ?? 0,
      ipAddress: json['ip_address']?.toString(),
      userAgent: json['user_agent']?.toString(),
      deviceUuid: json['device_uuid']?.toString(),
      loggedAt: json['logged_at']?.toString(),
      lastActivityAt: json['last_activity_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'user_id': userId,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      if (deviceUuid != null && deviceUuid!.isNotEmpty)
        'device_uuid': deviceUuid,
      'logged_at': loggedAt,
      'last_activity_at': lastActivityAt,
      'expires_at': expiresAt,
    };
  }
}
