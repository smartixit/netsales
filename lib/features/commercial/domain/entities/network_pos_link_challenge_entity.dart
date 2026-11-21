import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// كيان تحدي ودعوة ربط نقطة البيع بالشبكة عبر رمز QR
class NetworkPosLinkChallengeEntity extends Equatable {
  const NetworkPosLinkChallengeEntity({
    required this.challengeId,
    required this.challengeUuid,
    required this.payload,
    required this.networkId,
    this.posId,
    this.status,
    this.statusLabel,
    this.expiresAt,
    this.consumedAt,
    this.createdAt,
    this.updatedAt,
    this.network,
    this.pos,
  });

  final int challengeId;
  final String challengeUuid;
  final String payload;
  final int networkId;
  final int? posId;
  final String? status;
  final String? statusLabel;
  final String? expiresAt;
  final String? consumedAt;
  final String? createdAt;
  final String? updatedAt;
  final NetworkEntity? network;
  final PosEntity? pos;

  LinkingChallengeStatus get typedStatus =>
      LinkingChallengeStatus.fromWire(status);

  bool get isPending => typedStatus == LinkingChallengeStatus.pending;
  bool get isConsumed => typedStatus == LinkingChallengeStatus.consumed;
  bool get isExpired => typedStatus == LinkingChallengeStatus.expired;
  bool get isRevoked => typedStatus == LinkingChallengeStatus.revoked;

  @override
  List<Object?> get props => [
    challengeId,
    challengeUuid,
    payload,
    networkId,
    posId,
    status,
    statusLabel,
    expiresAt,
    consumedAt,
    createdAt,
    updatedAt,
    network,
    pos,
  ];
}
