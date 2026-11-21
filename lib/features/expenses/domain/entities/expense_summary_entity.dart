/// كائن الدومين النقي لملخص وإحصائيات المصروفات التشغيلية (ExpenseSummaryEntity)
///
/// يطابق عقد استجابة `GET /api/v1/expenses/summary` الصادر من الخادم.
class ExpenseSummaryEntity {
  const ExpenseSummaryEntity({
    this.totalCount = 0,
    this.totalAmount = 0.0,
    this.thisMonthAmount = 0.0,
    this.todayAmount = 0.0,
  });

  /// العدد الكلي لسندات المصروفات
  final int totalCount;

  /// المبلغ الكلي لجميع المصروفات المسجلة
  final double totalAmount;

  /// إجمالي مصروفات الشهر الحالي
  final double thisMonthAmount;

  /// إجمالي مصروفات اليوم
  final double todayAmount;
}
