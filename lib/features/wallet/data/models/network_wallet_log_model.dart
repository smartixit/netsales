import 'package:netsales/features/wallet/domain/entities/network_wallet_log_entity.dart';

/// نموذج بيانات قيد دفتر أستاذ محفظة مزود الشبكة (Network Wallet Log Model)
class NetworkWalletLogModel extends NetworkWalletLogEntity {
  const NetworkWalletLogModel({
    required super.logId,
    required super.walletId,
    super.operationTypeRaw,
    super.operationTypeLabel,
    required super.amount,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.balanceSnapshotSource,
    required super.currencyCode,
    required super.statement,
    super.logDate,
    super.createdBy,
    super.createdByName,
    super.createdAt,
  });

  factory NetworkWalletLogModel.fromJson(Map<String, dynamic> json) {
    final createdByUser = json['created_by_user'] as Map<String, dynamic>?;
    final createdByName =
        createdByUser?['name']?.toString() ??
        createdByUser?['user_name']?.toString();

    final rawLogId = json['log_id'] ?? json['id'];
    final rawWalletId = json['wallet_id'];
    final rawAmount = json['amount'] ?? json['log_amount'];
    final rawBalanceBefore = json['balance_before'];
    final rawBalanceAfter = json['balance_after'];
    final rawCreatedBy = json['created_by'];

    return NetworkWalletLogModel(
      logId: rawLogId is num
          ? rawLogId.toInt()
          : (int.tryParse(rawLogId?.toString() ?? '') ?? 0),
      walletId: rawWalletId is num
          ? rawWalletId.toInt()
          : (int.tryParse(rawWalletId?.toString() ?? '') ?? 0),
      operationTypeRaw: (json['log_operation'] ?? json['log_operation_type'])
          ?.toString(),
      operationTypeLabel:
          (json['log_operation_label'] ?? json['log_operation_type_label'])
              ?.toString(),
      amount: rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount?.toString() ?? '') ?? 0.0),
      balanceBefore: rawBalanceBefore is num
          ? rawBalanceBefore.toDouble()
          : (double.tryParse(rawBalanceBefore?.toString() ?? '') ?? 0.0),
      balanceAfter: rawBalanceAfter is num
          ? rawBalanceAfter.toDouble()
          : (double.tryParse(rawBalanceAfter?.toString() ?? '') ?? 0.0),
      balanceSnapshotSource:
          json['balance_snapshot_source']?.toString() ?? 'LIVE',
      currencyCode: (json['currency_code']?.toString() ?? 'YER')
          .trim()
          .toUpperCase(),
      statement: (json['statement'] ?? json['log_statement'])?.toString() ?? '',
      logDate: json['log_date']?.toString(),
      createdBy: rawCreatedBy is num
          ? rawCreatedBy.toInt()
          : int.tryParse(rawCreatedBy?.toString() ?? ''),
      createdByName: createdByName,
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': logId,
      'log_id': logId,
      'wallet_id': walletId,
      'log_operation': operationTypeRaw,
      'log_operation_label': operationTypeLabel,
      'amount': amount,
      'log_amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'balance_snapshot_source': balanceSnapshotSource,
      'currency_code': currencyCode,
      'statement': statement,
      'log_statement': statement,
      'log_date': logDate,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}
