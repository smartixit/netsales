import 'package:equatable/equatable.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// كيان بند المصروف التشغيلي (Expense Item Entity)
class ExpenseItemEntity extends Equatable {
  const ExpenseItemEntity({
    required this.itemId,
    required this.expenseId,
    required this.itemStatement,
    required this.itemAmount,
    this.createdAt,
    this.updatedAt,
  });

  final int itemId;
  final int expenseId;
  final String itemStatement;
  final double itemAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// مبلغ البند منسقاً للعرض
  String get formattedAmount =>
      AmountFormatter.format(itemAmount.toString());

  @override
  List<Object?> get props => [
        itemId,
        expenseId,
        itemStatement,
        itemAmount,
        createdAt,
        updatedAt,
      ];
}
