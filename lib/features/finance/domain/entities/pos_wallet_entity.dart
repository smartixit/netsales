/// كيان محفظة نقطة البيع والائتمان التجاري (POS Wallet Entity)
class PosWalletEntity {
  final int walletId;
  final int networkId;
  final int posId;
  final String? walletUuid;
  final double walletBalance;
  final double? creditLimit;
  final double availableOverdraftCapacity;
  final bool status;
  final String? accountingStatus;
  final String? accountingStatusLabel;
  final bool isOverdrawn;
  final double debitAmount;
  final double creditAmount;
  final String? networkName;
  final String? posName;
  final String? createdAt;
  final String? updatedAt;

  const PosWalletEntity({
    required this.walletId,
    required this.networkId,
    required this.posId,
    this.walletUuid,
    required this.walletBalance,
    this.creditLimit,
    this.availableOverdraftCapacity = 0.0,
    this.status = true,
    this.accountingStatus,
    this.accountingStatusLabel,
    this.isOverdrawn = false,
    this.debitAmount = 0.0,
    this.creditAmount = 0.0,
    this.networkName,
    this.posName,
    this.createdAt,
    this.updatedAt,
  });

  /// الرصيد المتاح الفعلي للاستخدام (الرصيد النقدي + السقف الائتماني المتبقي)
  double get totalPurchasingPower => walletBalance + availableOverdraftCapacity;
}

/// كيان قيد دفتر الأستاذ لمحفظة نقطة البيع (POS Wallet Log Entity)
class PosWalletLogEntity {
  final int logId;
  final int walletId;
  final String? logOperationType;
  final String? logOperationTypeLabel;
  final double logAmount;
  final String? logStatement;
  final String? logDate;
  final int? createdBy;
  final String? createdByName;
  final String? createdAt;

  const PosWalletLogEntity({
    required this.logId,
    required this.walletId,
    this.logOperationType,
    this.logOperationTypeLabel,
    required this.logAmount,
    this.logStatement,
    this.logDate,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });
}

