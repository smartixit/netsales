import 'package:netsales/core/enums/pos_status.dart';

/// كيان نقطة البيع التجارية (POS Commercial Entity)
class PosEntity {
  final int posId;
  final int ownerId;
  final String posUuid;
  final String posName;
  final String posPhoneNumber;
  final String? posEmail;
  final String? posAddress;
  final int? governorateId;
  final int? directorateId;
  final String? governorateName;
  final String? directorateName;
  final String? status;
  final String? statusLabel;
  final String? ownerName;
  final String? posProfileLogoUrl;
  final String? createdAt;
  final String? updatedAt;

  const PosEntity({
    required this.posId,
    required this.ownerId,
    required this.posUuid,
    required this.posName,
    required this.posPhoneNumber,
    this.posEmail,
    this.posAddress,
    this.governorateId,
    this.directorateId,
    this.governorateName,
    this.directorateName,
    this.status,
    this.statusLabel,
    this.ownerName,
    this.posProfileLogoUrl,
    this.createdAt,
    this.updatedAt,
  });

  PosStatus get typedStatus => PosStatus.fromWire(status);
  bool get isActive => typedStatus == PosStatus.active;
}
