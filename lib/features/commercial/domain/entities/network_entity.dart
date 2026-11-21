import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/network_status.dart';
import 'package:netsales/core/utils/date_formatter.dart';

/// كيان مزود الشبكة التجاري (Network Entity)
class NetworkEntity extends Equatable {
  const NetworkEntity({
    required this.networkId,
    required this.ownerId,
    required this.networkName,
    required this.networkPhoneNumber,
    this.networkUuid,
    this.networkEmail,
    this.networkAddress,
    this.governorateId,
    this.directorateId,
    this.governorateName,
    this.directorateName,
    this.status,
    this.statusLabel,
    this.ownerName,
    this.networkProfileLogoUrl,
    this.createdAt,
    this.updatedAt,
  });

  final int networkId;
  final int ownerId;
  final String networkName;
  final String networkPhoneNumber;
  final String? networkUuid;
  final String? networkEmail;
  final String? networkAddress;
  final int? governorateId;
  final int? directorateId;
  final String? governorateName;
  final String? directorateName;
  final String? status;
  final String? statusLabel;
  final String? ownerName;
  final String? networkProfileLogoUrl;
  final String? createdAt;
  final String? updatedAt;

  String get displayReference {
    if (networkUuid != null && networkUuid!.trim().isNotEmpty) {
      return networkUuid!.trim();
    }
    return '#$networkId';
  }

  String get displayName =>
      networkName.trim().isNotEmpty ? networkName.trim() : 'شبكة #$networkId';

  String get displayPhone => networkPhoneNumber.trim().isNotEmpty
      ? networkPhoneNumber.trim()
      : 'غير متوفر';

  String get displayOwnerName =>
      ownerName != null && ownerName!.trim().isNotEmpty
      ? ownerName!.trim()
      : 'غير محدد';

  String get displayLocation {
    final segments = <String>[
      if (governorateName != null && governorateName!.trim().isNotEmpty)
        governorateName!.trim(),
      if (directorateName != null && directorateName!.trim().isNotEmpty)
        directorateName!.trim(),
    ];
    final area = segments.join(' - ');
    final addr = networkAddress?.trim();
    if (area.isNotEmpty && addr != null && addr.isNotEmpty) {
      return '$area ($addr)';
    }
    if (area.isNotEmpty) return area;
    if (addr != null && addr.isNotEmpty) return addr;
    return 'غير محدد';
  }

  DateTime? get parsedCreatedAt => DateTime.tryParse(createdAt ?? '');

  String get formattedCreatedAt => parsedCreatedAt != null
      ? DateFormatter.date(parsedCreatedAt!)
      : (createdAt ?? 'غير متوفر');

  NetworkStatus get typedStatus => NetworkStatus.fromWire(status);
  bool get isActive => typedStatus == NetworkStatus.active;

  @override
  List<Object?> get props => [
    networkId,
    ownerId,
    networkUuid,
    networkName,
    networkPhoneNumber,
    networkEmail,
    networkAddress,
    governorateId,
    directorateId,
    governorateName,
    directorateName,
    status,
    statusLabel,
    ownerName,
    networkProfileLogoUrl,
    createdAt,
    updatedAt,
  ];
}
