/// ============================================================================
/// كائن مزود الشبكة الدوميني النقي (NetworkEntity)
/// ============================================================================
/// كائن دوميني نقي خالٍ تماماً من أي اعتماديات خارجية أو منطق تسلسل JSON.
class NetworkEntity {
  final int networkId;
  final String networkUuid;
  final String networkName;
  final String? networkProfileLogo;
  final String? networkPhoneNumber;
  final String? networkEmail;
  final String? networkAddress;
  final int governorateId;
  final int directorateId;
  final String? governorateName;
  final String? directorateName;
  final int ownerId;
  final String? ownerName;
  final String? ownerPhone;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String status;
  final int? posCount;
  final int? packagesCount;
  final DateTime? createdAt;

  const NetworkEntity({
    required this.networkId,
    required this.networkUuid,
    required this.networkName,
    this.networkProfileLogo,
    this.networkPhoneNumber,
    this.networkEmail,
    this.networkAddress,
    required this.governorateId,
    required this.directorateId,
    this.governorateName,
    this.directorateName,
    required this.ownerId,
    this.ownerName,
    this.ownerPhone,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    required this.status,
    this.posCount,
    this.packagesCount,
    this.createdAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isRejected => status.toUpperCase() == 'REJECTED';
  bool get isInactive => status.toUpperCase() == 'INACTIVE';
  bool get isBanned => status.toUpperCase() == 'BANNED';

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'مفعّل';
      case 'PENDING':
        return 'قيد المراجعة';
      case 'REJECTED':
        return 'مرفوض';
      case 'INACTIVE':
        return 'معطل';
      case 'BANNED':
        return 'محظور';
      default:
        return status;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkEntity &&
          runtimeType == other.runtimeType &&
          networkId == other.networkId;

  @override
  int get hashCode => networkId.hashCode;

  @override
  String toString() => 'NetworkEntity(id: $networkId, name: $networkName, status: $status)';
}
