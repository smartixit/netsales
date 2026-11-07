/// كيان بند فاتورة مبيعات الكروت (Sale Invoice Item Entity)
class InvoiceItemEntity {
  final int itemId;
  final int invoiceId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? packageName;
  final String? packageColor;
  final String? createdAt;
  final String? updatedAt;

  const InvoiceItemEntity({
    required this.itemId,
    required this.invoiceId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    this.itemDiscount = 0.0,
    required this.itemTotalAmount,
    this.packageName,
    this.packageColor,
    this.createdAt,
    this.updatedAt,
  });
}

