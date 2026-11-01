/// ============================================================================
/// كيانات معاينة التسعير والتعديل السيادي لطلب التوريد (Request Pricing Preview)
/// ============================================================================

class RequestPreviewItemEntity {
  final int packageId;
  final String packageName;
  final String? packageCategory;
  final int voucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double itemTotalAmount;
  final double grossTotalAmount;
  final double discountAmount;
  final String source; // ORIGINAL | REVIEW_CAPTURED
  final String? pricingToken;
  final String changeType; // UNCHANGED | QUANTITY_CHANGED | ADDED
  final int? originalVoucherCount;

  const RequestPreviewItemEntity({
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

  bool get isOriginal => source == 'ORIGINAL';
  bool get isReviewCaptured => source == 'REVIEW_CAPTURED';
  bool get isQuantityChanged => changeType == 'QUANTITY_CHANGED';
  bool get isAdded => changeType == 'ADDED';
}

class RequestPreviewRemovedItemEntity {
  final int packageId;
  final String packageName;
  final int originalVoucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double originalItemTotal;

  const RequestPreviewRemovedItemEntity({
    required this.packageId,
    required this.packageName,
    required this.originalVoucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.originalItemTotal,
  });
}

class RequestPricingPreviewEntity {
  final int requestId;
  final String requestUuid;
  final double originalTotalAmount;
  final double previewTotalAmount;
  final double grossTotalAmount;
  final double totalDiscountAmount;
  final String saleType;
  final String saleTypeLabel;
  final bool hasModifications;
  final List<RequestPreviewItemEntity> items;
  final List<RequestPreviewRemovedItemEntity> removedItems;

  const RequestPricingPreviewEntity({
    required this.requestId,
    required this.requestUuid,
    required this.originalTotalAmount,
    required this.previewTotalAmount,
    required this.grossTotalAmount,
    required this.totalDiscountAmount,
    required this.saleType,
    required this.saleTypeLabel,
    required this.hasModifications,
    required this.items,
    required this.removedItems,
  });
}

