/// ============================================================================
/// الكيان الدوميني النقي لفواتير مبيعات كروت الشبكة (SaleInvoiceEntity)
/// ============================================================================
/// يمثل بيانات فاتورة المبيعات الصادرة لنقطة بيع، خالي من أي منطق JSON.
class SaleInvoiceEntity {
  final int invoiceId;
  final int networkId;
  final int posId;
  final String invoiceUuid;
  final String saleType;
  final String saleTypeLabel;
  final double invoiceTotalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String paymentStatusLabel;
  final bool isFullyPaid;
  final String? invoiceDate;
  final int createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;
  final String? posName;
  final String? posCode;
  final List<SaleInvoiceItemEntity> items;

  const SaleInvoiceEntity({
    required this.invoiceId,
    required this.networkId,
    required this.posId,
    required this.invoiceUuid,
    required this.saleType,
    required this.saleTypeLabel,
    required this.invoiceTotalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.isFullyPaid,
    this.invoiceDate,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.posName,
    this.posCode,
    this.items = const [],
  });

  bool get isCash => saleType == 'CASH';
  bool get isCredit => saleType == 'CREDIT';
  bool get hasRemaining => remainingAmount > 0.001;
  int get totalCardsCount => items.fold(0, (sum, item) => sum + item.voucherCount);
}

/// بند من بنود فاتورة المبيعات (باقة كروت محددة مع السعر والكمية والخصم)
class SaleInvoiceItemEntity {
  final int itemId;
  final int invoiceId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? packageName;
  final String? createdAt;

  const SaleInvoiceItemEntity({
    required this.itemId,
    required this.invoiceId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    required this.itemDiscount,
    required this.itemTotalAmount,
    this.packageName,
    this.createdAt,
  });
}
