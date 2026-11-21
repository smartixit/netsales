import 'package:netsales/features/commercial/data/models/network_linkable_pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';

/// نموذج بيانات دعوة وتحدي ربط نقطة البيع بالشبكة عبر QR
class NetworkPosLinkChallengeModel extends NetworkPosLinkChallengeEntity {
  const NetworkPosLinkChallengeModel({
    required super.challengeId,
    required super.challengeUuid,
    required super.payload,
    required super.networkId,
    required super.posId,
    super.status,
    super.statusLabel,
    super.expiresAt,
    super.consumedAt,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.pos,
  });

  factory NetworkPosLinkChallengeModel.fromJson(Map<String, dynamic> json) {
    final networkData = json['network'];
    final networkName = networkData is Map<String, dynamic>
        ? networkData['network_name']?.toString()
        : null;

    NetworkLinkablePosModel? pModel;
    if (json['pos'] is Map<String, dynamic>) {
      pModel = NetworkLinkablePosModel.fromJson(
        json['pos'] as Map<String, dynamic>,
      );
    }

    return NetworkPosLinkChallengeModel(
      challengeId: (json['challenge_id'] as num?)?.toInt() ?? 0,
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num).toInt(),
      status: json['status']?.toString(),
      statusLabel: json['status_label']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      consumedAt: json['consumed_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      networkName: networkName,
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
      if (networkName != null)
        'network': {'network_id': networkId, 'network_name': networkName},
      if (pos != null)
        'pos': {
          'pos_id': pos!.posId,
          'pos_uuid': pos!.posUuid,
          'pos_name': pos!.posName,
        },
    };
  }
}
