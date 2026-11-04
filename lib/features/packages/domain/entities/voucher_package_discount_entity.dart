/// كيان الخصم التعاقدي الاستثنائي لنقطة البيع (Contractual Package Discount Entity)
class VoucherPackageDiscountEntity {
  final int discountId;
  final int networkId;
  final int posId;
  final int packageId;
  final double discountCash;
  final double discountCredit;
  final bool status;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final String? displayEndDate;
  final String validityState;
  final bool isEffectiveNow;

  /// الحسابات المالية المعتمدة سيادياً من الخادم (Display-Only §34)
  final double? originalPackagePrice;
  final double? effectiveCashPrice;
  final double? effectiveCreditPrice;
  final double? cashSavings;
  final double? creditSavings;

  final String? networkName;
  final String? posName;
  final String? packageName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VoucherPackageDiscountEntity({
    required this.discountId,
    required this.networkId,
    required this.posId,
    required this.packageId,
    required this.discountCash,
    required this.discountCredit,
    required this.status,
    this.discountStartDate,
    this.discountEndDate,
    this.displayEndDate,
    required this.validityState,
    required this.isEffectiveNow,
    this.originalPackagePrice,
    this.effectiveCashPrice,
    this.effectiveCreditPrice,
    this.cashSavings,
    this.creditSavings,
    this.networkName,
    this.posName,
    this.packageName,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status;
  bool get isCurrentlyValid => isEffectiveNow && isActive;
}

