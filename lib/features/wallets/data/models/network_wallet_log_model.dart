import 'package:netsales/features/wallets/domain/entities/network_wallet_log_entity.dart';

/// ============================================================================
/// نموذج بيانات سجل حركة محفظة الشبكة (NetworkWalletLogModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [NetworkWalletLogEntity] طبقاً لقواعد Clean Architecture.
class NetworkWalletLogModel extends NetworkWalletLogEntity {
  const NetworkWalletLogModel({
    required super.logId,
    required super.walletId,
    required super.logOperation,
    required super.logOperationLabel,
    required super.logAmount,
    super.logStatement,
    super.logDate,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory NetworkWalletLogModel.fromJson(Map<String, dynamic> json) {
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

    final op = json['log_operation']?.toString() ?? 'TRANSACTION';
    String opLabel = json['log_operation_label']?.toString() ?? '';
    if (opLabel.isEmpty) {
      switch (op.toUpperCase()) {
        case 'DEPOSIT':
          opLabel = 'إيداع نقدي';
          break;
        case 'WITHDRAW':
        case 'WITHDRAWAL':
          opLabel = 'سحب نقدي';
          break;
        case 'EXPENSE':
          opLabel = 'سند مصروفات';
          break;
        case 'INVOICE_PAYMENT':
          opLabel = 'تحصيل فاتورة مبيعات';
          break;
        case 'TRANSFER_TO_POS':
          opLabel = 'تحويل إلى نقطة بيع';
          break;
        case 'TRANSFER_FROM_POS':
          opLabel = 'تحويل من نقطة بيع';
          break;
        default:
          opLabel = op;
      }
    }

    return NetworkWalletLogModel(
      logId: (json['log_id'] as num?)?.toInt() ?? 0,
      walletId: (json['wallet_id'] as num?)?.toInt() ?? 0,
      logOperation: op,
      logOperationLabel: opLabel,
      logAmount: amount,
      logStatement: json['log_statement']?.toString(),
      logDate: parseDate(json['log_date']),
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'wallet_id': walletId,
      'log_operation': logOperation,
      'log_operation_label': logOperationLabel,
      'log_amount': logAmount,
      'log_statement': logStatement,
      'log_date': logDate?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

