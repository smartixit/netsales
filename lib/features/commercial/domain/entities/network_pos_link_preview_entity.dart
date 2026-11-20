import 'package:equatable/equatable.dart';
import 'package:netsales/core/utils/date_formatter.dart';
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

  String get networkName => network.displayName;

  String get displayNetworkName => network.displayName;

  String get displayNetworkPhone => network.displayPhone;

  String get displayNetworkLocation => network.displayLocation;

  String get displayNetworkReference => network.displayReference;

  DateTime? get parsedExpiresAt =>
      expiresAt != null ? DateTime.tryParse(expiresAt!) : null;

  String get formattedExpiry {
    final parsed = parsedExpiresAt;
    return parsed != null ? DateFormatter.dateTime(parsed) : 'غير محدد';
  }

  @override
  List<Object?> get props => [
        challengeUuid,
        network,
        pos,
        expiresAt,
        isTargeted,
      ];
}
