import 'package:netsales/features/commercial/data/models/network_model.dart';
import 'package:netsales/features/commercial/data/models/pos_model.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';

/// نموذج بيانات ارتباط نقطة البيع بالشبكة (Network–POS Link Data Model)
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

  factory NetworkPosLinkModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw FormatException(
        'Invalid JSON type for NetworkPosLinkModel: ${json.runtimeType}',
      );
    }

    NetworkModel? network;
    if (json['network'] is Map<String, dynamic>) {
      network = NetworkModel.fromJson(json['network'] as Map<String, dynamic>);
    }

    PosModel? pos;
    if (json['pos'] is Map<String, dynamic>) {
      pos = PosModel.fromJson(json['pos'] as Map<String, dynamic>);
    }

    return NetworkPosLinkModel(
      networkPosId: _toInt(json['network_pos_id']),
      networkId: _toInt(json['network_id']),
      posId: _toInt(json['pos_id']),
      status: _toBool(json['status']),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      network: network,
      pos: pos,
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
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return true;
  }
}
