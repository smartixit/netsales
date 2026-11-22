import 'package:netsales/core/enums/package_status.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';

/// كيان باقة كروت الإنترنت (Enterprise Package Entity)
class PackageEntity {
  final int packageId;
  final int networkId;
  final String packageName;
  final String? packageColor;
  final int packageBalance;
  final int? packageUptime;
  final int? packageValidity;
  final int packageVoucherCount;
  final double packageVoucherPrice;
  final double packageDefaultCashDiscount;
  final double packageDefaultCreditDiscount;

  /// الحسابات المالية المعتمدة سيادياً من الخادم (Server-Authoritative AGENTS.md §3)
  final double cashDiscountAmount;
  final double creditDiscountAmount;
  final double effectiveCashPrice;
  final double effectiveCreditPrice;

  final bool status;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? networkName;
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

  /// The API stores package balance in megabytes; convert to canonical bytes
  /// before using the shared data-size formatter.
  String get balanceDisplay => PackageSpecFormatter.formatData(
    PackageSpecFormatter.toCanonicalBytes(
      packageBalance,
      DataSizeUnit.megabytes,
    ),
  );

  String get uptimeDisplay =>
      PackageSpecFormatter.formatDuration(packageUptime);

  String get validityDisplay =>
      PackageSpecFormatter.formatDuration(packageValidity);
}
