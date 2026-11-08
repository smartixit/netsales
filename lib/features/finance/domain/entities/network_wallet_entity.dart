/// كيان محفظة مزود الشبكة ودفتر الأستاذ (Network Wallet Entity)
class NetworkWalletEntity {
  final int walletId;
  final int networkId;
  final String? walletUuid;
  final double walletBalance;
  final bool status;
  final String? networkName;
  final String? createdAt;
  final String? updatedAt;

  const NetworkWalletEntity({
    required this.walletId,
    required this.networkId,
    this.walletUuid,
    required this.walletBalance,
    this.status = true,
    this.networkName,
    this.createdAt,
    this.updatedAt,
  });
}

/// كيان قيد دفتر الأستاذ لمحفظة الشبكة (Network Wallet Log Entity)
class NetworkWalletLogEntity {
  final int logId;
  final int walletId;
  final String? logOperation;
  final String? logOperationLabel;
  final double logAmount;
  final String? logStatement;
  final String? logDate;
  final int? createdBy;
  final String? createdByName;
  final String? createdAt;

  const NetworkWalletLogEntity({
    required this.logId,
    required this.walletId,
    this.logOperation,
    this.logOperationLabel,
    required this.logAmount,
    this.logStatement,
    this.logDate,
    this.createdBy,
    this.createdByName,
    this.createdAt,
  });
}

