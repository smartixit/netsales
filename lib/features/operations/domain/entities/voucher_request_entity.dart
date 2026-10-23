/// ============================================================================
/// الكيان الدوميني النقي لطلبات توريد الكروت (VoucherRequestEntity)
/// ============================================================================
/// يمثل طلب توريد باقات كروت من نقطة بيع إلى مزود شبكة، خالي من أي منطق JSON.
class VoucherRequestEntity {
  final int requestId;
  final int networkId;
  final int posId;
  final String requestUuid;
  final String saleType;
  final String saleTypeLabel;
  final double requestTotalAmount;
  final String? requestDate;
  final String status;
  final String statusLabel;
  final int createdBy;
  final int? reviewedBy;
  final String? reviewDate;
  final String? requestNote;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;
  final String? posName;
  final String? posCode;
  final List<VoucherRequestItemEntity> items;

  const VoucherRequestEntity({
    required this.requestId,
    required this.networkId,
    required this.posId,
    required this.requestUuid,
    required this.saleType,
    required this.saleTypeLabel,
    required this.requestTotalAmount,
    this.requestDate,
    required this.status,
    required this.statusLabel,
    required this.createdBy,
    this.reviewedBy,
    this.reviewDate,
    this.requestNote,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.posName,
    this.posCode,
    this.items = const [],
  });

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCash => saleType == 'CASH';
  bool get isCredit => saleType == 'CREDIT';
  int get totalCardsCount => items.fold(0, (sum, item) => sum + item.voucherCount);
}

/// بند من بنود طلب توريد باقات الكروت
class VoucherRequestItemEntity {
  final int itemId;
  final int requestId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? packageName;
  final String? createdAt;

  const VoucherRequestItemEntity({
    required this.itemId,
    required this.requestId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    required this.itemDiscount,
    required this.itemTotalAmount,
    this.packageName,
    this.createdAt,
  });
}
