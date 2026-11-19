import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';

/// نموذج بيانات ارتباط نقطة البيع بالشبكة (Network POS Link Model)
class NetworkPosLinkModel extends NetworkPosLinkEntity {
  const NetworkPosLinkModel({
    required super.networkPosId,
    required super.networkId,
    required super.posId,
    required super.status,
    super.createdAt,
    super.updatedAt,
    super.network,
    super.pos,
  });

  factory NetworkPosLinkModel.fromJson(Map<String, dynamic> json) {
    return NetworkPosLinkModel(
      networkPosId: (json['network_pos_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      status: json['status'] == true ||
          json['status'] == 1 ||
          json['status'] == '1',
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
      'network_pos_id': networkPosId,
      'network_id': networkId,
      'pos_id': posId,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'network': network is NetworkModel ? (network as NetworkModel).toJson() : null,
      'pos': pos is PosModel ? (pos as PosModel).toJson() : null,
    };
  }
}
