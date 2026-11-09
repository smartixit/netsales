/// Canonical non-financial input for one line of a direct sale invoice.
class DirectInvoiceItemInputEntity {
  final int packageId;
  final int voucherCount;

  const DirectInvoiceItemInputEntity({
    required this.packageId,
    required this.voucherCount,
  });
}
