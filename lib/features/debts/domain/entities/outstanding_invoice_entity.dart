// ============================================================================
// كائن الفاتورة الآجلة المستحقة مع تصنيف عمر الدين (Outstanding Invoice Entity)
// ============================================================================

class PosOutstandingInvoiceEntity {
  final int invoiceId;
  final String invoiceUuid;
  final int networkId;
  final int posId;
  final double invoiceTotalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String paymentStatusLabel;
  final DateTime invoiceDate;
  final int daysOutstanding;
  final String agingBucket;

  const PosOutstandingInvoiceEntity({
    required this.invoiceId,
    required this.invoiceUuid,
    required this.networkId,
    required this.posId,
    required this.invoiceTotalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.invoiceDate,
    required this.daysOutstanding,
    required this.agingBucket,
  });

  bool get isFullyPaid => remainingAmount <= 0.001;
  bool get isPartiallyPaid => paidAmount > 0.001 && remainingAmount > 0.001;
  bool get isUnpaid => paidAmount <= 0.001;

  /// درجة الخطورة لعمر الفاتورة
  AgingRisk get riskLevel {
    if (daysOutstanding > 90) return AgingRisk.critical;
    if (daysOutstanding > 60) return AgingRisk.high;
    if (daysOutstanding > 30) return AgingRisk.medium;
    return AgingRisk.normal;
  }
}

enum AgingRisk {
  normal,   // 0-30 days
  medium,   // 31-60 days
  high,     // 61-90 days
  critical, // >90 days
}
