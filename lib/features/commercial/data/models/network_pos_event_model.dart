import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';

class NetworkPosEventModel extends NetworkPosEventEntity {
  const NetworkPosEventModel({
    required super.eventId,
    required super.networkPosId,
    required super.eventType,
    required super.createdAt,
    super.payload,
    super.actorName,
  });

  factory NetworkPosEventModel.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'];
    return NetworkPosEventModel(
      eventId: (json['event_id'] as num?)?.toInt() ?? 0,
      networkPosId: (json['network_pos_id'] as num?)?.toInt() ?? 0,
      eventType: json['event_type']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      payload: json['payload'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['payload'] as Map<String, dynamic>)
          : const {},
      actorName: actor is Map<String, dynamic> ? actor['user_full_name']?.toString() : null,
    );
  }
}
