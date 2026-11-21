/// كائن الدومين النقي لمدخل بند مصروف جديد (NewExpenseItemInputEntity)
///
/// يمثل عنصراً نقياً في طبقة الدومين بدون أي تبعيات تسلسلية (خالٍ تماماً من toJson / fromJson).
class NewExpenseItemInputEntity {
  const NewExpenseItemInputEntity({
    required this.itemStatement,
    required this.itemAmount,
  });

  /// البيان النصي للبند
  final String itemStatement;

  /// المبلغ المالي للبند
  final double itemAmount;
}
