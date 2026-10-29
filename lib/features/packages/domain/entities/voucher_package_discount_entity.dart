/// ============================================================================
/// كيان خصم باقة الكروت المخصص لنقطة بيع (VoucherPackageDiscountEntity)
/// ============================================================================
/// كائن نقي يمثل نسبة الخصم المخصصة الاستثنائية لنقطة بيع معينة على باقة محددة،
/// خالٍ من أي ارتباط بقواعد التسلسل أو الحزم الخارجية.
/// القيم المالية المشتقة (effectiveCashPrice, cashSavings, ...) تأتي جاهزة من
/// الخادم (Single Source of Truth) ولا تُحتسب داخل العميل.
class VoucherPackageDiscountEntity {
  final int discountId;
  final int networkId;
  final int posId;
  final int packageId;
  final double discountCash;
  final double discountCredit;
  final bool status;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;
  final String? posName;
  final String? packageName;

  // Server-authoritative derived monetary values (Display-Only, AGENTS.md §34)
  final double? originalPackagePrice;
  final double? effectiveCashPrice;
  final double? effectiveCreditPrice;
  final double? cashSavings;
  final double? creditSavings;

  const VoucherPackageDiscountEntity({
    required this.discountId,
    required this.networkId,
    required this.posId,
    required this.packageId,
    required this.discountCash,
    required this.discountCredit,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.posName,
    this.packageName,
    this.originalPackagePrice,
    this.effectiveCashPrice,
    this.effectiveCreditPrice,
    this.cashSavings,
    this.creditSavings,
  });

  /// فحص تفعيل الخصم المخصص
  bool get isActive => status;

  /// نسخة معدلة من الكيان
  VoucherPackageDiscountEntity copyWith({
    int? discountId,
    int? networkId,
    int? posId,
    int? packageId,
    double? discountCash,
    double? discountCredit,
    bool? status,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    String? networkName,
    String? posName,
    String? packageName,
    double? originalPackagePrice,
    double? effectiveCashPrice,
    double? effectiveCreditPrice,
    double? cashSavings,
    double? creditSavings,
  }) {
    return VoucherPackageDiscountEntity(
      discountId: discountId ?? this.discountId,
      networkId: networkId ?? this.networkId,
      posId: posId ?? this.posId,
      packageId: packageId ?? this.packageId,
      discountCash: discountCash ?? this.discountCash,
      discountCredit: discountCredit ?? this.discountCredit,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      networkName: networkName ?? this.networkName,
      posName: posName ?? this.posName,
      packageName: packageName ?? this.packageName,
      originalPackagePrice: originalPackagePrice ?? this.originalPackagePrice,
      effectiveCashPrice: effectiveCashPrice ?? this.effectiveCashPrice,
      effectiveCreditPrice: effectiveCreditPrice ?? this.effectiveCreditPrice,
      cashSavings: cashSavings ?? this.cashSavings,
      creditSavings: creditSavings ?? this.creditSavings,
    );
  }
}
