import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';

/// نموذج بيانات ارتباط نقطة البيع بالشبكة (Network-POS Link Model)
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
    NetworkModel? networkModel;
    if (json['network'] is Map<String, dynamic>) {
      networkModel = NetworkModel.fromJson(json['network'] as Map<String, dynamic>);
    }

    PosModel? posModel;
    if (json['pos'] is Map<String, dynamic>) {
      posModel = PosModel.fromJson(json['pos'] as Map<String, dynamic>);
    }

    // قراءة الحالة بدقة سواء جاءت boolean أو رقم 1/0 أو نص
    final rawStatus = json['status'];
    final bool parsedStatus;
    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus is num) {
      parsedStatus = rawStatus == 1;
    } else if (rawStatus is String) {
      parsedStatus = rawStatus == '1' || rawStatus.toUpperCase() == 'ACTIVE' || rawStatus.toUpperCase() == 'TRUE';
    } else {
      parsedStatus = true;
    }

    return NetworkPosLinkModel(
      networkPosId: (json['network_pos_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      status: parsedStatus,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      network: networkModel,
      pos: posModel,
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
      if (network != null && network is NetworkModel)
        'network': (network! as NetworkModel).toJson(),
      if (pos != null && pos is PosModel)
        'pos': (pos! as PosModel).toJson(),
    };
  }
}
