/// ============================================================================
/// كيان خصم باقة الكروت المخصص لنقطة بيع (VoucherPackageDiscountEntity)
/// ============================================================================
/// كائن نقي يمثل نسبة الخصم المخصصة الاستثنائية لنقطة بيع معينة على باقة محددة،
/// خالٍ من أي ارتباط بقواعد التسلسل أو الحزم الخارجية.
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
  final double? originalPackagePrice;

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
  });

  /// فحص تفعيل الخصم المخصص
  bool get isActive => status;

  /// احتساب السعر الصافي بالريال لنقطة البيع عند الشراء النقدي
  double getEffectiveCashPrice(double basePrice) {
    final discountAmount = (basePrice * discountCash) / 100;
    return basePrice - discountAmount;
  }

  /// احتساب السعر الصافي بالريال لنقطة البيع عند الشراء الآجل
  double getEffectiveCreditPrice(double basePrice) {
    final discountAmount = (basePrice * discountCredit) / 100;
    return basePrice - discountAmount;
  }

  /// مقدار التوفير المالي (ربح نقطة البيع) بالريال عند الدفع النقدي
  double getCashSavings(double basePrice) => (basePrice * discountCash) / 100;

  /// مقدار التوفير المالي (ربح نقطة البيع) بالريال عند الدفع الآجل
  double getCreditSavings(double basePrice) =>
      (basePrice * discountCredit) / 100;

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
    );
  }
}
