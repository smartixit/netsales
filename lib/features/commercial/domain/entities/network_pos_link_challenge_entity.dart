import 'package:netsales/core/enums/linking_challenge_status.dart';

/// كيان دعوة ربط نقطة البيع بالشبكة عبر QR
class NetworkPosLinkChallengeEntity {
  final String challengeUuid;
  final int networkId;
  final String? networkName;
  final int? posId;
  final String? posName;
  final String payloadToken;
  final LinkingChallengeStatus status;
  final String? statusLabel;
  final DateTime expiresAt;
  final DateTime? createdAt;

  const NetworkPosLinkChallengeEntity({
    required this.challengeUuid,
    required this.networkId,
    this.networkName,
    this.posId,
    this.posName,
    required this.payloadToken,
    required this.status,
    this.statusLabel,
    required this.expiresAt,
    this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == LinkingChallengeStatus.pending && !isExpired;
}

