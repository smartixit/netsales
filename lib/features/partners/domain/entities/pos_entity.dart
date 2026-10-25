/// ============================================================================
/// كائن نقطة البيع / الوكيل الدوميني النقي (PosEntity)
/// ============================================================================
/// كائن دوميني نقي خالٍ تماماً من أي اعتماديات خارجية أو منطق تسلسل JSON.
class PosEntity {
  final int posId;
  final String posUuid;
  final String posName;
  final String? posProfileLogo;
  final String? posPhoneNumber;
  final String? posEmail;
  final String? posAddress;
  final int governorateId;
  final int directorateId;
  final String? governorateName;
  final String? directorateName;
  final int ownerId;
  final String? agentName;
  final String? agentPhone;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final String status;
  final int? networksCount;
  final DateTime? createdAt;

  const PosEntity({
    required this.posId,
    required this.posUuid,
    required this.posName,
    this.posProfileLogo,
    this.posPhoneNumber,
    this.posEmail,
    this.posAddress,
    required this.governorateId,
    required this.directorateId,
    this.governorateName,
    this.directorateName,
    required this.ownerId,
    this.agentName,
    this.agentPhone,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    required this.status,
    this.networksCount,
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
      other is PosEntity &&
          runtimeType == other.runtimeType &&
          posId == other.posId;

  @override
  int get hashCode => posId.hashCode;

  @override
  String toString() => 'PosEntity(id: $posId, name: $posName, status: $status)';
}
