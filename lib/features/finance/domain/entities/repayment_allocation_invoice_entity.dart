/// بيانات الفاتورة التي أعادها Laravel ضمن توزيع سند السداد.
class RepaymentAllocationInvoiceEntity {
  final String invoiceUuid;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String invoiceDate;
  final String saleType;
  final String saleTypeLabel;

  const RepaymentAllocationInvoiceEntity({
    required this.invoiceUuid,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.invoiceDate,
    required this.saleType,
    required this.saleTypeLabel,
  });
}
