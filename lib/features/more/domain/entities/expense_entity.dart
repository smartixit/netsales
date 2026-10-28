/// ============================================================================
/// كائن المصروف التشغيلي الدوميني النقي (ExpenseEntity)
/// ============================================================================
/// يمثل قيد مصروف تشغيلي موثق في نظام المنشأة.
class ExpenseEntity {
  final int expenseId;
  final int networkId;
  final String expenseUuid;
  final double expenseTotalAmount;
  final DateTime? expenseDate;
  final int itemsCount;
  final int attachmentsCount;
  final String? createdByName;
  final DateTime? createdAt;

  const ExpenseEntity({
    required this.expenseId,
    required this.networkId,
    required this.expenseUuid,
    required this.expenseTotalAmount,
    this.expenseDate,
    this.itemsCount = 0,
    this.attachmentsCount = 0,
    this.createdByName,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntity &&
          runtimeType == other.runtimeType &&
          expenseId == other.expenseId;

  @override
  int get hashCode => expenseId.hashCode;

  @override
  String toString() =>
      'ExpenseEntity(id: $expenseId, uuid: $expenseUuid, amount: $expenseTotalAmount)';
}
