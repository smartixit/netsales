import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/user_session_status.dart';
import 'package:netsales/core/utils/date_formatter.dart';

/// كيان جلسة تسجيل الدخول للمستخدم المصادَق (User Session Entity).
class UserSessionEntity extends Equatable {
  const UserSessionEntity({
    required this.sessionId,
    required this.userId,
    this.ipAddress,
    this.userAgent,
    this.deviceUuid,
    this.status,
    this.statusLabel,
    this.isCurrent = false,
    this.loggedAt,
    this.lastActivityAt,
    this.expiresAt,
    this.revokedAt,
  });

  final int sessionId;
  final int userId;
  final String? ipAddress;
  final String? userAgent;
  final String? deviceUuid;
  final String? status;
  final String? statusLabel;
  final bool isCurrent;
  final String? loggedAt;
  final String? lastActivityAt;
  final String? expiresAt;
  final String? revokedAt;

  UserSessionStatus get typedStatus => UserSessionStatus.fromWire(status);

  bool get isActive => typedStatus == UserSessionStatus.active;

  String get displayClient {
    final agent = userAgent?.trim() ?? '';
    if (agent.isEmpty) return 'جلسة دخول #$sessionId';
    if (agent.length <= 42) return agent;
    return '${agent.substring(0, 39)}...';
  }

  String get shortDeviceUuid {
    final uuid = deviceUuid?.trim() ?? '';
    if (uuid.isEmpty) return '';
    if (uuid.length <= 12) return uuid;
    return '${uuid.substring(0, 6)}...${uuid.substring(uuid.length - 4)}';
  }

  String get formattedLastActivity => _formatSmart(lastActivityAt);

  String get formattedLoggedAt => _formatDateTime(loggedAt);

  String get formattedExpiresAt => _formatDateTime(expiresAt);

  String get formattedRevokedAt => _formatDateTime(revokedAt);

  String _formatSmart(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'غير معروف';
    final parsed = DateTime.tryParse(raw);
    return parsed != null ? DateFormatter.smart(parsed) : raw;
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '---';
    final parsed = DateTime.tryParse(raw);
    return parsed != null ? DateFormatter.dateTime(parsed) : raw;
  }

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    ipAddress,
    userAgent,
    deviceUuid,
    status,
    statusLabel,
    isCurrent,
    loggedAt,
    lastActivityAt,
    expiresAt,
    revokedAt,
  ];
}
