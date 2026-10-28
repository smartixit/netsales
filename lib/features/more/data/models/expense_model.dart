import 'package:netsales/features/more/domain/entities/expense_entity.dart';

/// ============================================================================
/// نموذج بيانات المصروف التشغيلي (ExpenseModel)
/// ============================================================================
class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.expenseId,
    required super.networkId,
    required super.expenseUuid,
    required super.expenseTotalAmount,
    super.expenseDate,
    super.itemsCount,
    super.attachmentsCount,
    super.createdByName,
    super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final rawAmount = json['expense_total_amount'];
    final double amount = (rawAmount is num)
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;

    final createdByUser = json['created_by_user'] is Map
        ? json['created_by_user'] as Map<String, dynamic>
        : null;

    final items = json['items'] is List ? json['items'] as List : null;
    final attachments =
        json['attachments'] is List ? json['attachments'] as List : null;

    return ExpenseModel(
      expenseId: (json['expense_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      expenseUuid: json['expense_uuid']?.toString() ?? '',
      expenseTotalAmount: amount,
      expenseDate: parseDate(json['expense_date']),
      itemsCount: items?.length ?? (json['items_count'] as num?)?.toInt() ?? 0,
      attachmentsCount: attachments?.length ??
          (json['attachments_count'] as num?)?.toInt() ??
          0,
      createdByName: createdByUser?['user_full_name']?.toString() ??
          json['created_by_name']?.toString(),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'network_id': networkId,
      'expense_uuid': expenseUuid,
      'expense_total_amount': expenseTotalAmount,
      'expense_date': expenseDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
