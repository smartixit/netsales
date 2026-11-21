import 'package:netsales/core/enums/linking_challenge_status.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';

/// نموذج استجابة حالة الدعوة الآمنة من الخادم.
class NetworkPosLinkChallengeStatusModel
    extends NetworkPosLinkChallengeStatusEntity {
  const NetworkPosLinkChallengeStatusModel({
    required super.status,
    super.statusLabel,
    super.expiresAt,
  });

  factory NetworkPosLinkChallengeStatusModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NetworkPosLinkChallengeStatusModel(
      status: LinkingChallengeStatus.fromWire(json['status']?.toString()),
      statusLabel: json['status_label']?.toString(),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }
}
