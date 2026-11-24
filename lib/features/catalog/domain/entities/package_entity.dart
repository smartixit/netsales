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

  /// فئة الكرت / سعر الكرت الواحد الأساسي
  double get unitVoucherPrice => resolvedBasePrice;

  /// سعر الكرت الواحد الفعلي نقداً بعد الخصم
  double get unitCashPrice => resolvedCashPrice;

  /// سعر الكرت الواحد الفعلي آجلاً بعد الخصم
  double get unitCreditPrice => resolvedCreditPrice;

  /// إجمالي قيمة الحزمة الأساسية قبل الخصم (سعر الكرت * عدد الكروت)
  double get totalPackageBasePrice =>
      resolvedBasePrice * (packageVoucherCount > 0 ? packageVoucherCount : 1);

  /// إجمالي قيمة الحزمة نقداً بعد الخصم
  double get totalCashPrice =>
      resolvedCashPrice * (packageVoucherCount > 0 ? packageVoucherCount : 1);

  /// إجمالي قيمة الحزمة آجلاً بعد الخصم
  double get totalCreditPrice =>
      resolvedCreditPrice * (packageVoucherCount > 0 ? packageVoucherCount : 1);

  /// إجمالي مبلغ التوفير للحزمة نقداً
  double get totalCashSavings =>
      cashDiscountAmount * (packageVoucherCount > 0 ? packageVoucherCount : 1);

  /// إجمالي مبلغ التوفير للحزمة آجلاً
  double get totalCreditSavings =>
      creditDiscountAmount * (packageVoucherCount > 0 ? packageVoucherCount : 1);
}
