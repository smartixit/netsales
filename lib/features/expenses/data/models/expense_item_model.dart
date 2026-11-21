import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';

/// نموذج بيانات بند المصروف (ExpenseItemModel)
///
/// يطابق تمثيل الـ JSON الصادر من `ExpenseItemResource.php` في الخادم.
class ExpenseItemModel extends ExpenseItemEntity {
  const ExpenseItemModel({
    required super.itemId,
    required super.expenseId,
    required super.itemStatement,
    required super.itemAmount,
    super.createdAt,
    super.updatedAt,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      itemId: json['item_id'] is int
          ? json['item_id'] as int
          : int.tryParse(json['item_id']?.toString() ?? '0') ?? 0,
      expenseId: json['expense_id'] is int
          ? json['expense_id'] as int
          : int.tryParse(json['expense_id']?.toString() ?? '0') ?? 0,
      itemStatement: json['item_statement']?.toString() ?? '',
      itemAmount: json['item_amount'] is num
          ? (json['item_amount'] as num).toDouble()
          : double.tryParse(json['item_amount']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'expense_id': expenseId,
    'item_statement': itemStatement,
    'item_amount': itemAmount,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
