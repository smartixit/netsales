/// ============================================================================
/// كائن الجلسة المصرح بها الدوميني النقي (UserSessionEntity)
/// ============================================================================
/// يمثل جلسة دخول نشطة ومصرح بها لحساب المستخدم، خالية من أي بيانات أمنية حساسة أو شفرات.
class UserSessionEntity {
  final int sessionId;
  final int userId;
  final String ipAddress;
  final String userAgent;
  final String deviceUuid;
  final DateTime? loggedAt;
  final DateTime? lastActivityAt;
  final DateTime? expiresAt;
  final bool isCurrentSession;

  const UserSessionEntity({
    required this.sessionId,
    required this.userId,
    required this.ipAddress,
    required this.userAgent,
    required this.deviceUuid,
    this.loggedAt,
    this.lastActivityAt,
    this.expiresAt,
    this.isCurrentSession = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSessionEntity &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId;

  @override
  int get hashCode => sessionId.hashCode;

  @override
  String toString() =>
      'UserSessionEntity(id: $sessionId, device: $userAgent, current: $isCurrentSession)';
}
