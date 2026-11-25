import 'package:equatable/equatable.dart';

class NetworkPosEventEntity extends Equatable {
  const NetworkPosEventEntity({
    required this.eventId,
    required this.networkPosId,
    required this.eventType,
    required this.createdAt,
    this.payload = const {},
    this.actorName,
  });

  final int eventId;
  final int networkPosId;
  final String eventType;
  final String createdAt;
  final Map<String, dynamic> payload;
  final String? actorName;

  @override
  List<Object?> get props => [eventId, networkPosId, eventType, createdAt, payload, actorName];
}
