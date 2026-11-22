/// كيان مبيعات اليوم التنفيذي لمزود الشبكة (Network Daily Sales Entity)
class NetworkDailySalesEntity {
  const NetworkDailySalesEntity({
    required this.amount,
    required this.invoiceCount,
    required this.yesterdayAmount,
    required this.growthRate,
  });

  /// إجمالي قيمة مبيعات اليوم كقيمة نصية عشرية دقيقة
  final String amount;

  /// عدد فواتير مبيعات اليوم
  final int invoiceCount;

  /// إجمالي قيمة مبيعات الأمس للمقارنة
  final String yesterdayAmount;

  /// نسبة النمو أو الانخفاض المئوية مقارنة بالأمس
  final double growthRate;
}
