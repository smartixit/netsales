/// ============================================================================
/// كيان باقة كروت الإنترنت (VoucherPackageEntity)
/// ============================================================================
/// كائن نقي يمثل بيانات باقة الكروت، الأسعار، الحصص، الصلاحية، ونسب الخصم
/// الافتراضية، خالٍ تماماً من أي اعتماديات خارجية أو منطق تسلسل JSON.
/// القيم المالية المشتقة (cashDiscountAmount, effectiveCashPrice, ...) تأتي
/// جاهزة من الخادم (Single Source of Truth) ولا تُحتسب في العميل.
class VoucherPackageEntity {
  final int packageId;
  final int networkId;
  final String packageName;
  final String? packageColor;
  final double? packageBalance;
  final String? packageUptime;
  final String? packageValidity;
  final int packageVoucherCount;
  final double packageVoucherPrice;
  final double packageDefaultCashDiscount;
  final double packageDefaultCreditDiscount;
  final bool status;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? networkName;

  // Server-authoritative derived monetary values (Display-Only, AGENTS.md §34)
  final double cashDiscountAmount;
  final double creditDiscountAmount;
  final double effectiveCashPrice;
  final double effectiveCreditPrice;

  const VoucherPackageEntity({
    required this.packageId,
    required this.networkId,
    required this.packageName,
    this.packageColor,
    this.packageBalance,
    this.packageUptime,
    this.packageValidity,
    this.packageVoucherCount = 0,
    required this.packageVoucherPrice,
    required this.packageDefaultCashDiscount,
    required this.packageDefaultCreditDiscount,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.cashDiscountAmount = 0.0,
    this.creditDiscountAmount = 0.0,
    this.effectiveCashPrice = 0.0,
    this.effectiveCreditPrice = 0.0,
  });

  /// فحص تفعيل الباقة
  bool get isActive => status;

  /// نسخة معدلة من الكيان
  VoucherPackageEntity copyWith({
    int? packageId,
    int? networkId,
    String? packageName,
    String? packageColor,
    double? packageBalance,
    String? packageUptime,
    String? packageValidity,
    int? packageVoucherCount,
    double? packageVoucherPrice,
    double? packageDefaultCashDiscount,
    double? packageDefaultCreditDiscount,
    bool? status,
    int? createdBy,
    String? createdAt,
    String? updatedAt,
    String? networkName,
    double? cashDiscountAmount,
    double? creditDiscountAmount,
    double? effectiveCashPrice,
    double? effectiveCreditPrice,
  }) {
    return VoucherPackageEntity(
      packageId: packageId ?? this.packageId,
      networkId: networkId ?? this.networkId,
      packageName: packageName ?? this.packageName,
      packageColor: packageColor ?? this.packageColor,
      packageBalance: packageBalance ?? this.packageBalance,
      packageUptime: packageUptime ?? this.packageUptime,
      packageValidity: packageValidity ?? this.packageValidity,
      packageVoucherCount: packageVoucherCount ?? this.packageVoucherCount,
      packageVoucherPrice: packageVoucherPrice ?? this.packageVoucherPrice,
      packageDefaultCashDiscount:
          packageDefaultCashDiscount ?? this.packageDefaultCashDiscount,
      packageDefaultCreditDiscount:
          packageDefaultCreditDiscount ?? this.packageDefaultCreditDiscount,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      networkName: networkName ?? this.networkName,
      cashDiscountAmount: cashDiscountAmount ?? this.cashDiscountAmount,
      creditDiscountAmount: creditDiscountAmount ?? this.creditDiscountAmount,
      effectiveCashPrice: effectiveCashPrice ?? this.effectiveCashPrice,
      effectiveCreditPrice: effectiveCreditPrice ?? this.effectiveCreditPrice,
    );
  }
}
