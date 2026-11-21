import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';

/// Data representation of the minimal exact POS-resolution response.
class NetworkLinkablePosModel extends NetworkLinkablePosEntity {
  const NetworkLinkablePosModel({
    required super.posId,
    required super.posUuid,
    required super.posName,
  });

  factory NetworkLinkablePosModel.fromJson(Map<String, dynamic> json) {
    return NetworkLinkablePosModel(
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      posUuid: json['pos_uuid']?.toString() ?? '',
      posName: json['pos_name']?.toString() ?? '',
    );
  }
}
