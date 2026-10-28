import 'package:netsales/features/partners/domain/entities/pos_wallet_entity.dart';

/// ============================================================================
/// نموذج بيانات محفظة نقطة البيع الثنائية (PosWalletModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [PosWalletEntity] طبقاً لقواعد Clean Architecture.
/// يتولى فك تسلسل بيانات JSON الواردة من netsales_api بأعلى درجات الأمان النوعي.
class PosWalletModel extends PosWalletEntity {
  const PosWalletModel({
    required super.walletId,
    required super.networkId,
    required super.posId,
    required super.walletUuid,
    required super.walletBalance,
    required super.status,
    required super.accountingStatus,
    required super.accountingStatusLabel,
    required super.isOverdrawn,
    required super.debitAmount,
    required super.creditAmount,
    super.networkName,
    super.posName,
    super.createdAt,
    super.updatedAt,
  });

  factory PosWalletModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawBalance = json['wallet_balance'];
    final double balance = (rawBalance is num)
        ? rawBalance.toDouble()
        : double.tryParse(rawBalance?.toString() ?? '') ?? 0.0;

    final rawDebit = json['debit_amount'];
    final double debit = (rawDebit is num)
        ? rawDebit.toDouble()
        : double.tryParse(rawDebit?.toString() ?? '') ?? 0.0;

    final rawCredit = json['credit_amount'];
    final double credit = (rawCredit is num)
        ? rawCredit.toDouble()
        : double.tryParse(rawCredit?.toString() ?? '') ?? 0.0;

    final bool isOverdrawn = json['is_overdrawn'] == true;
    final String accountingStatus = json['accounting_status']?.toString() ?? 'ZERO';
    final String accountingStatusLabel = json['accounting_status_label']?.toString() ?? '';

    final network = json['network'] is Map ? json['network'] as Map<String, dynamic> : null;
    final pos = json['pos'] is Map ? json['pos'] as Map<String, dynamic> : null;

    return PosWalletModel(
      walletId: (json['wallet_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      walletUuid: json['wallet_uuid']?.toString() ?? '',
      walletBalance: balance,
      status: json['status'] == true || json['status'] == 1,
      accountingStatus: accountingStatus,
      accountingStatusLabel: accountingStatusLabel,
      isOverdrawn: isOverdrawn,
      debitAmount: debit,
      creditAmount: credit,
      networkName: network?['network_name']?.toString() ?? json['network_name']?.toString(),
      posName: pos?['pos_name']?.toString() ?? json['pos_name']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'network_id': networkId,
      'pos_id': posId,
      'wallet_uuid': walletUuid,
      'wallet_balance': walletBalance,
      'status': status,
      'accounting_status': accountingStatus,
      'accounting_status_label': accountingStatusLabel,
      'is_overdrawn': isOverdrawn,
      'debit_amount': debitAmount,
      'credit_amount': creditAmount,
      'network_name': networkName,
      'pos_name': posName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// ============================================================================
/// نموذج بيانات سجل قيد محفظة نقطة البيع (PosWalletLogModel)
/// ============================================================================
class PosWalletLogModel extends PosWalletLogEntity {
  const PosWalletLogModel({
    required super.logId,
    required super.walletId,
    required super.logOperationType,
    required super.logOperationTypeLabel,
    required super.logAmount,
    super.logStatement,
    super.logDate,
    super.createdBy,
    super.createdAt,
  });

  factory PosWalletLogModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawAmount = json['log_amount'];
    final double amount = (rawAmount is num)
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;

    final opType = json['log_operation_type']?.toString() ?? 'TRANSACTION';
    String opLabel = json['log_operation_type_label']?.toString() ?? '';
    if (opLabel.isEmpty) {
      switch (opType.toUpperCase()) {
        case 'DEPOSIT':
          opLabel = 'إيداع / تغذية';
          break;
        case 'WITHDRAW':
          opLabel = 'سحب / مشتريات';
          break;
        case 'TRANSFER':
          opLabel = 'تحويل بيني';
          break;
        default:
          opLabel = opType;
      }
    }

    return PosWalletLogModel(
      logId: (json['log_id'] as num?)?.toInt() ?? 0,
      walletId: (json['wallet_id'] as num?)?.toInt() ?? 0,
      logOperationType: opType,
      logOperationTypeLabel: opLabel,
      logAmount: amount,
      logStatement: json['log_statement']?.toString(),
      logDate: parseDate(json['log_date']),
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'wallet_id': walletId,
      'log_operation_type': logOperationType,
      'log_operation_type_label': logOperationTypeLabel,
      'log_amount': logAmount,
      'log_statement': logStatement,
      'log_date': logDate?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
