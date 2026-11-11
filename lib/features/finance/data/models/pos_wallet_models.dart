import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';

class PosWalletModel extends PosWalletEntity {
  const PosWalletModel({
    required super.walletId,
    required super.networkId,
    required super.posId,
    super.walletUuid,
    required super.walletBalance,
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
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble(),
      availableOverdraftCapacity:
          (json['available_overdraft_capacity'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as bool? ?? true,
      accountingStatus: json['accounting_status'] as String?,
      accountingStatusLabel: json['accounting_status_label'] as String?,
      isOverdrawn: json['is_overdrawn'] as bool? ?? false,
      debitAmount: (json['debit_amount'] as num?)?.toDouble() ?? 0.0,
      creditAmount: (json['credit_amount'] as num?)?.toDouble() ?? 0.0,
      totalPurchasingPower:
          (json['total_purchasing_power'] as num?)?.toDouble(),
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
      logAmount: (json['log_amount'] as num?)?.toDouble() ?? 0.0,
      logStatement: json['log_statement'] as String?,
      logDate: json['log_date'] as String?,
      createdBy: json['created_by'] as int?,
      createdByName: creatorName,
      createdAt: json['created_at'] as String?,
    );
  }
}
