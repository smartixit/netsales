import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';

/// نموذج بيانات فحص ومعاينة دعوة الارتباط المشفرة
class NetworkPosLinkPreviewModel extends NetworkPosLinkPreviewEntity {
  const NetworkPosLinkPreviewModel({
    required super.challengeUuid,
    required super.network,
    super.pos,
    super.expiresAt,
    super.isTargeted = false,
  });

  factory NetworkPosLinkPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawNetwork = json['network'];
    final NetworkModel netModel;
    if (rawNetwork is Map<String, dynamic>) {
      netModel = NetworkModel.fromJson(rawNetwork);
    } else {
      netModel = const NetworkModel(
        networkId: 0,
        ownerId: 0,
        networkName: '',
        networkPhoneNumber: '',
      );
    }

    PosModel? pModel;
    final rawPos = json['pos'];
    if (rawPos is Map<String, dynamic>) {
      pModel = PosModel.fromJson(rawPos);
    }

    return NetworkPosLinkPreviewModel(
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      network: netModel,
      pos: pModel,
      expiresAt: json['expires_at']?.toString(),
      isTargeted: json['is_targeted'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_uuid': challengeUuid,
      'network': (network is NetworkModel)
          ? (network as NetworkModel).toJson()
          : null,
      'pos': (pos != null && pos is PosModel)
          ? (pos! as PosModel).toJson()
          : null,
      'expires_at': expiresAt,
      'is_targeted': isTargeted,
    };
  }
}
