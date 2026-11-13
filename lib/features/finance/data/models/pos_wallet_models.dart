import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';

double? _readWalletDecimal(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class PosWalletModel extends PosWalletEntity {
  const PosWalletModel({
    required super.walletId,
    required super.networkId,
    required super.posId,
    super.walletUuid,
    required super.walletBalance,
    super.openingBalance,
    super.openingBalanceSource,
    super.currencyCode,
    super.networkProfileLogo,
    super.posProfileLogo,
    super.creditLimit,
    super.availableOverdraftCapacity = 0.0,
    super.status = true,
    super.accountingStatus,
    super.accountingStatusLabel,
    super.isOverdrawn = false,
    super.debitAmount = 0.0,
    super.creditAmount = 0.0,
    super.networkName,
    super.posName,
    super.totalPurchasingPower,
    super.createdAt,
    super.updatedAt,
  });

  factory PosWalletModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName =
          (json['network'] as Map<String, dynamic>)['network_name'] as String?;
    }

    String? pName;
    if (json['pos'] is Map<String, dynamic>) {
      pName = (json['pos'] as Map<String, dynamic>)['pos_name'] as String?;
    }

    return PosWalletModel(
      walletId: json['wallet_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      walletUuid: json['wallet_uuid'] as String?,
      walletBalance: _readWalletDecimal(json['wallet_balance']) ?? 0.0,
      openingBalance: _readWalletDecimal(json['opening_balance']),
      openingBalanceSource: json['opening_balance_source'] as String?,
      currencyCode: json['currency_code'] as String?,
      networkProfileLogo: json['network'] is Map<String, dynamic>
          ? (json['network'] as Map<String, dynamic>)['network_profile_logo'] as String?
          : null,
      posProfileLogo: json['pos'] is Map<String, dynamic>
          ? (json['pos'] as Map<String, dynamic>)['pos_profile_logo'] as String?
          : null,
      creditLimit: _readWalletDecimal(json['credit_limit']),
      availableOverdraftCapacity:
          _readWalletDecimal(json['available_overdraft_capacity']) ?? 0.0,
      status: json['status'] as bool? ?? true,
      accountingStatus: json['accounting_status'] as String?,
      accountingStatusLabel: json['accounting_status_label'] as String?,
      isOverdrawn: json['is_overdrawn'] as bool? ?? false,
      debitAmount: _readWalletDecimal(json['debit_amount']) ?? 0.0,
      creditAmount: _readWalletDecimal(json['credit_amount']) ?? 0.0,
      totalPurchasingPower:
          _readWalletDecimal(json['total_purchasing_power']),
      networkName: netName,
      posName: pName,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class PosWalletLogModel extends PosWalletLogEntity {
  const PosWalletLogModel({
    required super.logId,
    required super.walletId,
    super.logOperationType,
    super.logOperationTypeLabel,
    required super.logAmount,
    super.balanceBefore,
    super.balanceAfter,
    super.balanceSnapshotSource,
    super.currencyCode,
    super.logStatement,
    super.logDate,
    super.createdBy,
    super.createdByName,
    super.createdAt,
  });

  factory PosWalletLogModel.fromJson(Map<String, dynamic> json) {
    String? creatorName;
    if (json['created_by_user'] is Map<String, dynamic>) {
      creatorName =
          (json['created_by_user'] as Map<String, dynamic>)['full_name']
              as String?;
    }

    return PosWalletLogModel(
      logId: json['log_id'] as int? ?? 0,
      walletId: json['wallet_id'] as int? ?? 0,
      logOperationType: json['log_operation_type'] as String?,
      logOperationTypeLabel: json['log_operation_type_label'] as String?,
      logAmount: _readWalletDecimal(json['log_amount']) ?? 0.0,
      balanceBefore: _readWalletDecimal(json['balance_before']),
      balanceAfter: _readWalletDecimal(json['balance_after']),
      balanceSnapshotSource: json['balance_snapshot_source'] as String?,
      currencyCode: json['currency_code'] as String?,
      logStatement: json['log_statement'] as String?,
      logDate: json['log_date'] as String?,
      createdBy: json['created_by'] as int?,
      createdByName: creatorName,
      createdAt: json['created_at'] as String?,
    );
  }
}
