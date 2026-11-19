import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';

/// نموذج بيانات فحص ومعاينة دعوة الربط المشفرة
class NetworkPosLinkPreviewModel extends NetworkPosLinkPreviewEntity {
  const NetworkPosLinkPreviewModel({
    required super.challengeUuid,
    required super.network,
    super.pos,
    super.expiresAt,
    super.isTargeted,
  });

  factory NetworkPosLinkPreviewModel.fromJson(Map<String, dynamic> json) {
    final netData = json['network'] as Map<String, dynamic>? ?? {};
    final posData = json['pos'] as Map<String, dynamic>?;

    return NetworkPosLinkPreviewModel(
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      network: NetworkModel.fromJson(netData),
      pos: posData != null ? PosModel.fromJson(posData) : null,
      expiresAt: json['expires_at']?.toString(),
      isTargeted: json['is_targeted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_uuid': challengeUuid,
      'network': network is NetworkModel
          ? (network as NetworkModel).toJson()
          : null,
      'pos': pos is PosModel ? (pos as PosModel).toJson() : null,
      'expires_at': expiresAt,
      'is_targeted': isTargeted,
    };
  }
}
