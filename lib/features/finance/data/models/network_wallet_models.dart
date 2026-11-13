import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';

double? _readWalletDecimal(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class NetworkWalletModel extends NetworkWalletEntity {
  const NetworkWalletModel({
    required super.walletId,
    required super.networkId,
    super.walletUuid,
    required super.walletBalance,
    super.openingBalance,
    super.openingBalanceSource,
    super.currencyCode,
    super.networkProfileLogo,
    super.status = true,
    super.networkName,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkWalletModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName =
          (json['network'] as Map<String, dynamic>)['network_name'] as String?;
    }

    return NetworkWalletModel(
      walletId: json['wallet_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      walletUuid: json['wallet_uuid'] as String?,
      walletBalance: _readWalletDecimal(json['wallet_balance']) ?? 0.0,
      openingBalance: _readWalletDecimal(json['opening_balance']),
      openingBalanceSource: json['opening_balance_source'] as String?,
      currencyCode: json['currency_code'] as String?,
      networkProfileLogo: json['network'] is Map<String, dynamic>
          ? (json['network'] as Map<String, dynamic>)['network_profile_logo'] as String?
          : null,
      status: json['status'] as bool? ?? true,
      networkName: netName,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class NetworkWalletLogModel extends NetworkWalletLogEntity {
  const NetworkWalletLogModel({
    required super.logId,
    required super.walletId,
    super.logOperation,
    super.logOperationLabel,
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

  factory NetworkWalletLogModel.fromJson(Map<String, dynamic> json) {
    String? creatorName;
    if (json['created_by_user'] is Map<String, dynamic>) {
      creatorName =
          (json['created_by_user'] as Map<String, dynamic>)['full_name']
              as String?;
    }

    return NetworkWalletLogModel(
      logId: json['log_id'] as int? ?? 0,
      walletId: json['wallet_id'] as int? ?? 0,
      logOperation: json['log_operation'] as String?,
      logOperationLabel: json['log_operation_label'] as String?,
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
