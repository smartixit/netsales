/// ============================================================================
/// كائن محفظة نقطة البيع الثنائية الدوميني النقي (PosWalletEntity)
/// ============================================================================
/// يمثل الحساب المالي الجاري والائتماني المشترك بين الشبكة ونقطة البيع.
class PosWalletEntity {
  final int walletId;
  final int networkId;
  final int posId;
  final String walletUuid;
  final double walletBalance;
  final bool status;
  final String accountingStatus;
  final String accountingStatusLabel;
  final bool isOverdrawn;
  final double debitAmount;
  final double creditAmount;
  final String? networkName;
  final String? posName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PosWalletEntity({
    required this.walletId,
    required this.networkId,
    required this.posId,
    required this.walletUuid,
    required this.walletBalance,
    required this.status,
    required this.accountingStatus,
    required this.accountingStatusLabel,
    required this.isOverdrawn,
    required this.debitAmount,
    required this.creditAmount,
    this.networkName,
    this.posName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status;
  bool get isDebtor => accountingStatus.toUpperCase() == 'DEBIT';
  bool get isCreditor => accountingStatus.toUpperCase() == 'CREDIT';
  bool get isBalanced => accountingStatus.toUpperCase() == 'ZERO';


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PosWalletEntity &&
          runtimeType == other.runtimeType &&
          walletId == other.walletId;

  @override
  int get hashCode => walletId.hashCode;

  @override
  String toString() =>
      'PosWalletEntity(id: $walletId, balance: $walletBalance, status: $accountingStatusLabel)';
}

/// ============================================================================
/// كائن سجل حركة محفظة نقطة البيع الدوميني النقي (PosWalletLogEntity)
/// ============================================================================
/// يمثل قيداً مالياً في دفتر الأستاذ للحركات بين الشبكة ونقطة البيع.
class PosWalletLogEntity {
  final int logId;
  final int walletId;
  final String logOperationType;
  final String logOperationTypeLabel;
  final double logAmount;
  final String? logStatement;
  final DateTime? logDate;
  final int? createdBy;
  final DateTime? createdAt;

  const PosWalletLogEntity({
    required this.logId,
    required this.walletId,
    required this.logOperationType,
    required this.logOperationTypeLabel,
    required this.logAmount,
    this.logStatement,
    this.logDate,
    this.createdBy,
    this.createdAt,
  });

  bool get isCredit =>
      logOperationType.toUpperCase() == 'CREDIT' ||
      logOperationType.toUpperCase() == 'DEPOSIT';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PosWalletLogEntity &&
          runtimeType == other.runtimeType &&
          logId == other.logId;

  @override
  int get hashCode => logId.hashCode;
}
