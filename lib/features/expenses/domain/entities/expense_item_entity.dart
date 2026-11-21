/// كائن الدومين النقي لبند المصروف الفردي (ExpenseItemEntity)
///
/// يمثل بياناً ومبلغاً فرعياً ضمن سند المصروف التشغيلي.
class ExpenseItemEntity {
  const ExpenseItemEntity({
    required this.itemId,
    required this.expenseId,
    required this.itemStatement,
    required this.itemAmount,
    this.createdAt,
    this.updatedAt,
  });

  /// المعرف الرقمي للبند
  final int itemId;

  /// معرف المصروف التابع له
  final int expenseId;

  /// البيان النصي للبند (مثال: إيجار مقر، صيانة كوابل، اشتراك كهرباء)
  final String itemStatement;

  /// المبلغ المخصص للبند
  final double itemAmount;

  /// تاريخ الإضافة
  final DateTime? createdAt;

  /// تاريخ التعديل
  final DateTime? updatedAt;
}
