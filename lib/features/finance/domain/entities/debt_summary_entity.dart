/// كيان ملخص الذمم المدينة وتحليل الشرائح العمرية للديون (Receivables & Aging Summary Entity)
class DebtSummaryEntity {
  /// Aggregate remaining debt returned by Laravel.
  final double totalReceivables;

  /// Invoice counts are kept separately to preserve the backend contract.
  final int unpaidInvoicesCount;
  final int partiallyPaidInvoicesCount;

  /// Canonical aging keys used by the presentation layer.
  final Map<String, double> agingBuckets;

  final String? oldestOutstandingInvoiceDate;
  final int? networkId;
  final int? posId;

  int get totalOutstandingInvoices =>
      unpaidInvoicesCount + partiallyPaidInvoicesCount;

  const DebtSummaryEntity({
    required this.totalReceivables,
    this.unpaidInvoicesCount = 0,
    this.partiallyPaidInvoicesCount = 0,
    this.agingBuckets = const {},
    this.oldestOutstandingInvoiceDate,
    this.networkId,
    this.posId,
  });
}

