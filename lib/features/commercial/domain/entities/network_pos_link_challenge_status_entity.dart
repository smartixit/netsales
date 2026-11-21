import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';

/// الحالة الآمنة لدعوة الربط، دون تحميل حمولة QR أو معرفات التحدي.
class NetworkPosLinkChallengeStatusEntity extends Equatable {
  const NetworkPosLinkChallengeStatusEntity({
    required this.status,
    this.statusLabel,
    this.expiresAt,
  });

  final LinkingChallengeStatus status;
  final String? statusLabel;
  final DateTime? expiresAt;

  bool get isPending => status == LinkingChallengeStatus.pending;
  bool get isConsumed => status == LinkingChallengeStatus.consumed;
  bool get isExpired => status == LinkingChallengeStatus.expired;
  bool get isRevoked => status == LinkingChallengeStatus.revoked;

  bool isActiveAt(DateTime referenceTime) {
    final expiry = expiresAt;
    return isPending && expiry != null && expiry.isAfter(referenceTime);
  }

  @override
  List<Object?> get props => [status, statusLabel, expiresAt];
}
