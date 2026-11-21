import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';

/// نموذج بيانات دعوة وتحدي ربط نقطة البيع بالشبكة عبر QR
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
    NetworkModel? netModel;
    if (json['network'] is Map<String, dynamic>) {
      netModel = NetworkModel.fromJson(json['network'] as Map<String, dynamic>);
    }

    PosModel? pModel;
    if (json['pos'] is Map<String, dynamic>) {
      pModel = PosModel.fromJson(json['pos'] as Map<String, dynamic>);
    }

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
      network: netModel,
      pos: pModel,
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
      if (network != null && network is NetworkModel)
        'network': (network! as NetworkModel).toJson(),
      if (pos != null && pos is PosModel) 'pos': (pos! as PosModel).toJson(),
    };
  }
}
