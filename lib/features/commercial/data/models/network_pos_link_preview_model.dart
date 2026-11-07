import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';

class NetworkPosLinkPreviewModel extends NetworkPosLinkPreviewEntity {
  const NetworkPosLinkPreviewModel({
    required super.challengeUuid,
    required super.networkId,
    required super.networkName,
    super.networkPhone,
    super.governorateName,
    super.directorateName,
    super.posId,
    super.posName,
    required super.expiresAt,
    required super.alreadyLinked,
  });

  factory NetworkPosLinkPreviewModel.fromJson(Map<String, dynamic> json) {
    final net = json['network'] as Map<String, dynamic>? ?? {};
    final pos = json['pos'] as Map<String, dynamic>?;

    final rawExpires = json['expires_at']?.toString();
    final expiresAt = rawExpires != null
        ? DateTime.tryParse(rawExpires) ?? DateTime.now()
        : DateTime.now();

    return NetworkPosLinkPreviewModel(
      challengeUuid: json['challenge_uuid']?.toString() ?? '',
      networkId: (net['network_id'] as num?)?.toInt() ?? 0,
      networkName: net['network_name']?.toString() ?? 'شبكة غير معروفة',
      networkPhone: net['network_phone_number']?.toString(),
      governorateName: net['governorate']?.toString(),
      directorateName: net['directorate']?.toString(),
      posId: (pos?['pos_id'] as num?)?.toInt(),
      posName: pos?['pos_name']?.toString(),
      expiresAt: expiresAt,
      alreadyLinked: json['already_linked'] == true,
    );
  }
}
