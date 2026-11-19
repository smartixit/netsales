class RequestModificationRemovedItemEntity {
  final int packageId;
  final String packageName;
  final int originalVoucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double originalItemTotal;

  const RequestModificationRemovedItemEntity({
    required this.packageId,
    required this.packageName,
    required this.originalVoucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.originalItemTotal,
  });
}
