import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';

/// نموذج بيانات تحدي ودعوة ربط نقطة البيع بالشبكة عبر QR
class NetworkPosLinkChallengeModel extends NetworkPosLinkChallengeEntity {
  const NetworkPosLinkChallengeModel({
    required super.challengeId,
    required super.challengeUuid,
    required super.payload,
    required super.networkId,
    super.posId,
    super.status,
    super.statusLabel,
    super.expiresAt,
    super.consumedAt,
    super.createdAt,
    super.updatedAt,
    super.network,
    super.pos,
  });

  factory NetworkPosLinkChallengeModel.fromJson(Map<String, dynamic> json) {
    return NetworkPosLinkChallengeModel(
      challengeId: (json['challenge_id'] as num?)?.toInt() ?? 0,
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      consumedAt: json['consumed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      network: json['network'] is Map<String, dynamic>
          ? NetworkModel.fromJson(json['network'] as Map<String, dynamic>)
          : null,
      pos: json['pos'] is Map<String, dynamic>
          ? PosModel.fromJson(json['pos'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'challenge_uuid': challengeUuid,
      'payload': payload,
      'network_id': networkId,
      'pos_id': posId,
      'status': status,
      'status_label': statusLabel,
      'expires_at': expiresAt,
      'consumed_at': consumedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
