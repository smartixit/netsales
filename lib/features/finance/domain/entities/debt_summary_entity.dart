/// كيان ملخص الذمم المدينة وتحليل الشرائح العمرية للديون (Receivables & Aging Summary Entity)
class DebtSummaryEntity {
  final double totalReceivables;
  final int totalOutstandingInvoices;
  final Map<String, double> agingBuckets; // '0_30', '31_60', '61_90', 'over_90'
  final int? networkId;
  final int? posId;

  const DebtSummaryEntity({
    required this.totalReceivables,
    required this.totalOutstandingInvoices,
    this.agingBuckets = const {},
    this.networkId,
    this.posId,
  });
}

