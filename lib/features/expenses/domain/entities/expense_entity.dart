class ExpenseEntity {
  final int expenseId;
  final int networkId;
  final String expenseUuid;
  final double totalAmount;
  final String? expenseDate;
  final String? networkName;
  final List<ExpenseItemEntity> items;

  const ExpenseEntity({
    required this.expenseId,
    required this.networkId,
    required this.expenseUuid,
    required this.totalAmount,
    this.expenseDate,
    this.networkName,
    this.items = const [],
  });
}

class ExpenseItemEntity {
  final int itemId;
  final String statement;
  final double amount;

  const ExpenseItemEntity({
    required this.itemId,
    required this.statement,
    required this.amount,
  });
}
