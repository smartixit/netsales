import 'package:equatable/equatable.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';

/// كيان معاينة دعوة الربط المشفرة بعد مسح رمز QR
class NetworkPosLinkPreviewEntity extends Equatable {
  const NetworkPosLinkPreviewEntity({
    required this.challengeUuid,
    required this.network,
    this.pos,
    this.expiresAt,
    this.isTargeted = false,
  });

  final String challengeUuid;
  final NetworkEntity network;
  final PosEntity? pos;
  final String? expiresAt;
  final bool isTargeted;

  @override
  List<Object?> get props => [
        challengeUuid,
        network,
        pos,
        expiresAt,
        isTargeted,
      ];
}
