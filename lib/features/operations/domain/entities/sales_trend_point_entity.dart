/// ============================================================================
/// كيان نقطة في سلسلة مبيعات الكروت (SalesTrendPointEntity)
/// ============================================================================
/// كائن نقي يمثل نقطة في سلسلة زمنية حقيقية لمبيعات الكروت (من الخادم).
class SalesTrendPointEntity {
  final String period;
  final double total;
  final int count;

  const SalesTrendPointEntity({
    required this.period,
    required this.total,
    required this.count,
  });
}
