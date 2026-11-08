/// Canonical non-financial input for one line of a direct sale invoice.
class DirectInvoiceItemInput {
  final int packageId;
  final int voucherCount;

  const DirectInvoiceItemInput({
    required this.packageId,
    required this.voucherCount,
  });
}
