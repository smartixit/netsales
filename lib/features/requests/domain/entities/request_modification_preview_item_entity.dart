class RequestModificationPreviewItemEntity {
  final int packageId;
  final String packageName;
  final String? packageCategory;
  final int voucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double itemTotalAmount;
  final double grossTotalAmount;
  final double discountAmount;
  final String source;
  final String? pricingToken;
  final String changeType;
  final int? originalVoucherCount;

  const RequestModificationPreviewItemEntity({
    required this.packageId,
    required this.packageName,
    this.packageCategory,
    required this.voucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.itemTotalAmount,
    required this.grossTotalAmount,
    required this.discountAmount,
    required this.source,
    this.pricingToken,
    required this.changeType,
    this.originalVoucherCount,
  });

  /// هل البند مضاف حديثاً للمسودة؟
  bool get isAdded => changeType == 'ITEM_ADDED';

  /// هل تم تعديل كمية البند؟
  bool get isModified => changeType == 'QUANTITY_MODIFIED';

  /// هل البند دون تعديل في الكمية؟
  bool get isUnchanged => !isAdded && !isModified;
}
