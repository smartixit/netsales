import 'package:netsales/features/finance/domain/entities/network_wallet_entity.dart';

class NetworkWalletModel extends NetworkWalletEntity {
  const NetworkWalletModel({
    required super.walletId,
    required super.networkId,
    super.walletUuid,
    required super.walletBalance,
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
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
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
      logAmount: (json['log_amount'] as num?)?.toDouble() ?? 0.0,
      logStatement: json['log_statement'] as String?,
      logDate: json['log_date'] as String?,
      createdBy: json['created_by'] as int?,
      createdByName: creatorName,
      createdAt: json['created_at'] as String?,
    );
  }
}
