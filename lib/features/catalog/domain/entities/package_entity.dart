import 'package:netsales/core/enums/package_status.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';

/// كيان باقة كروت الإنترنت النقي (Enterprise Voucher Package Entity)
class PackageEntity {
  final int packageId;
  final int networkId;
  final String packageName;
  final String? packageColor;
  final int packageBalance; // بالبايت
  final int? packageUptime; // بالدقائق
  final int? packageValidity; // بالدقائق
  final int packageVoucherCount;
  final double packageVoucherPrice;
  final double packageDefaultCashDiscount;
  final double packageDefaultCreditDiscount;

  /// الحسابات المالية المعتمدة سيادياً من الخادم (Server-Authoritative)
  final double cashDiscountAmount;
  final double creditDiscountAmount;
  final double effectiveCashPrice;
  final double effectiveCreditPrice;

  final bool status;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? networkName;

  /// تعرفة الشراء الموقعة لنقاط البيع (DEC-PROC-01)
  final int? procurementBaseUnitPriceMinor;
  final int? procurementCashUnitPriceMinor;
  final int? procurementCreditUnitPriceMinor;
  final int? procurementCashDiscountBasisPoints;
  final int? procurementCreditDiscountBasisPoints;
  final String? procurementPricingSnapshotToken;
  final DateTime? procurementPricingSnapshotExpiresAt;
  final bool procurementIsCustomDiscount;

  const PackageEntity({
    required this.packageId,
    required this.networkId,
    required this.packageName,
    this.packageColor,
    required this.packageBalance,
    this.packageUptime,
    this.packageValidity,
    required this.packageVoucherCount,
    required this.packageVoucherPrice,
    required this.packageDefaultCashDiscount,
    required this.packageDefaultCreditDiscount,
    required this.cashDiscountAmount,
    required this.creditDiscountAmount,
    required this.effectiveCashPrice,
    required this.effectiveCreditPrice,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.networkName,
    this.procurementBaseUnitPriceMinor,
    this.procurementCashUnitPriceMinor,
    this.procurementCreditUnitPriceMinor,
    this.procurementCashDiscountBasisPoints,
    this.procurementCreditDiscountBasisPoints,
    this.procurementPricingSnapshotToken,
    this.procurementPricingSnapshotExpiresAt,
    this.procurementIsCustomDiscount = false,
  });

  PackageStatus get packageStatus => PackageStatus.fromWire(status);
  bool get isActive => packageStatus.isActive;

  /// السعر الأساسي للباقة محولاً من العملة الصغرى عند توفره
  double get resolvedBasePrice => procurementBaseUnitPriceMinor != null
      ? procurementBaseUnitPriceMinor! / 100.0
      : packageVoucherPrice;

  /// سعر الشراء النقدي الفعلي محولاً من العملة الصغرى
  double get resolvedCashPrice => procurementCashUnitPriceMinor != null
      ? procurementCashUnitPriceMinor! / 100.0
      : effectiveCashPrice;

  /// سعر الشراء الآجل الفعلي محولاً من العملة الصغرى
  double get resolvedCreditPrice => procurementCreditUnitPriceMinor != null
      ? procurementCreditUnitPriceMinor! / 100.0
      : effectiveCreditPrice;

  /// نسبة الخصم النقدي المحولة من نقاط الأساس
  double get resolvedCashDiscount => procurementCashDiscountBasisPoints != null
      ? procurementCashDiscountBasisPoints! / 100.0
      : packageDefaultCashDiscount;

  /// نسبة الخصم الآجل المحولة من نقاط الأساس
  double get resolvedCreditDiscount =>
      procurementCreditDiscountBasisPoints != null
      ? procurementCreditDiscountBasisPoints! / 100.0
      : packageDefaultCreditDiscount;

  /// تنسيق الرصيد عبر محول السعات المعتمد مباشرة بالبايت
  String get balanceDisplay => PackageSpecFormatter.formatData(packageBalance);

  String get uptimeDisplay =>
      PackageSpecFormatter.formatDuration(packageUptime);

  String get validityDisplay =>
      PackageSpecFormatter.formatDuration(packageValidity);

  /// تكلفة الكرت الواحد الأساسية
  double get unitVoucherPrice => packageVoucherCount > 0
      ? packageVoucherPrice / packageVoucherCount
      : packageVoucherPrice;

  /// تكلفة الكرت الواحد الفعلية نقداً
  double get unitCashPrice => packageVoucherCount > 0
      ? effectiveCashPrice / packageVoucherCount
      : effectiveCashPrice;

  /// تكلفة الكرت الواحد الفعلية آجلاً
  double get unitCreditPrice => packageVoucherCount > 0
      ? effectiveCreditPrice / packageVoucherCount
      : effectiveCreditPrice;

  PackageEntity copyWith({
    int? packageId,
    int? networkId,
    String? packageName,
    String? packageColor,
    int? packageBalance,
    int? packageUptime,
    int? packageValidity,
    int? packageVoucherCount,
    double? packageVoucherPrice,
    double? packageDefaultCashDiscount,
    double? packageDefaultCreditDiscount,
    double? cashDiscountAmount,
    double? creditDiscountAmount,
    double? effectiveCashPrice,
    double? effectiveCreditPrice,
    bool? status,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? networkName,
    int? procurementBaseUnitPriceMinor,
    int? procurementCashUnitPriceMinor,
    int? procurementCreditUnitPriceMinor,
    int? procurementCashDiscountBasisPoints,
    int? procurementCreditDiscountBasisPoints,
    String? procurementPricingSnapshotToken,
    DateTime? procurementPricingSnapshotExpiresAt,
    bool? procurementIsCustomDiscount,
  }) {
    return PackageEntity(
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
      cashDiscountAmount: cashDiscountAmount ?? this.cashDiscountAmount,
      creditDiscountAmount: creditDiscountAmount ?? this.creditDiscountAmount,
      effectiveCashPrice: effectiveCashPrice ?? this.effectiveCashPrice,
      effectiveCreditPrice: effectiveCreditPrice ?? this.effectiveCreditPrice,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      networkName: networkName ?? this.networkName,
      procurementBaseUnitPriceMinor:
          procurementBaseUnitPriceMinor ?? this.procurementBaseUnitPriceMinor,
      procurementCashUnitPriceMinor:
          procurementCashUnitPriceMinor ?? this.procurementCashUnitPriceMinor,
      procurementCreditUnitPriceMinor:
          procurementCreditUnitPriceMinor ??
          this.procurementCreditUnitPriceMinor,
      procurementCashDiscountBasisPoints:
          procurementCashDiscountBasisPoints ??
          this.procurementCashDiscountBasisPoints,
      procurementCreditDiscountBasisPoints:
          procurementCreditDiscountBasisPoints ??
          this.procurementCreditDiscountBasisPoints,
      procurementPricingSnapshotToken:
          procurementPricingSnapshotToken ??
          this.procurementPricingSnapshotToken,
      procurementPricingSnapshotExpiresAt:
          procurementPricingSnapshotExpiresAt ??
          this.procurementPricingSnapshotExpiresAt,
      procurementIsCustomDiscount:
          procurementIsCustomDiscount ?? this.procurementIsCustomDiscount,
    );
  }
}
