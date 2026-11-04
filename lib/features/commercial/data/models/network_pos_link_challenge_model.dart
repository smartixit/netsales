import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';

class NetworkPosLinkChallengeModel extends NetworkPosLinkChallengeEntity {
  const NetworkPosLinkChallengeModel({
    required super.challengeUuid,
    required super.networkId,
    super.networkName,
    super.posId,
    super.posName,
    required super.payloadToken,
    required super.status,
    super.statusLabel,
    required super.expiresAt,
    super.createdAt,
  });

  factory NetworkPosLinkChallengeModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName = json['network']['network_name'] as String?;
    }

    String? pointName;
    if (json['pos'] is Map<String, dynamic>) {
      pointName = json['pos']['pos_name'] as String?;
    }

    final rawStatus = json['status']?.toString();
    final parsedStatus = LinkingChallengeStatus.fromWire(rawStatus);

    final rawExpiresAt = json['expires_at']?.toString();
    final expiresAt = rawExpiresAt != null
        ? DateTime.tryParse(rawExpiresAt) ?? DateTime.now()
        : DateTime.now();

    final rawCreatedAt = json['created_at']?.toString();
    final createdAt = rawCreatedAt != null
        ? DateTime.tryParse(rawCreatedAt)
        : null;

    return NetworkPosLinkChallengeModel(
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      networkName: netName,
      posId: (json['pos_id'] as num?)?.toInt(),
      posName: pointName,
      payloadToken: json['payload_token']?.toString() ?? '',
      status: parsedStatus,
      statusLabel: json['status_label']?.toString(),
      expiresAt: expiresAt,
      createdAt: createdAt,
    );
  }
}
