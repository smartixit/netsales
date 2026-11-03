import 'package:netsales/features/commercial/domain/entities/network_status.dart';

/// كيان مزود الشبكة التجاري (Network Commercial Entity)
class NetworkEntity {
  final int networkId;
  final int ownerId;
  final String networkName;
  final String networkPhoneNumber;
  final String? networkEmail;
  final String? networkAddress;
  final int? governorateId;
  final int? directorateId;
  final String? status;
  final String? statusLabel;
  final String? ownerName;
  final String? networkProfileLogoUrl;
  final String? createdAt;
  final String? updatedAt;

  const NetworkEntity({
    required this.networkId,
    required this.ownerId,
    required this.networkName,
    required this.networkPhoneNumber,
    this.networkEmail,
    this.networkAddress,
    this.governorateId,
    this.directorateId,
    this.status,
    this.statusLabel,
    this.ownerName,
    this.networkProfileLogoUrl,
    this.createdAt,
    this.updatedAt,
  });

  NetworkStatus get typedStatus => NetworkStatus.fromWire(status);
  bool get isActive => typedStatus == NetworkStatus.active;
}
