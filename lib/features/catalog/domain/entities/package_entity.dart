import 'package:netsales/core/utils/package_spec_formatter.dart';

/// كيان باقة كروت الإنترنت (Enterprise Package Entity)
class PackageEntity {
  final int packageId;
  final int networkId;
  final String packageName;
  final String? packageColor;
  final double packageBalance;
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
  });

  bool get isActive => status;

  String get balanceDisplay =>
      PackageSpecFormatter.formatBalance(packageBalance);

  String get uptimeDisplay => PackageSpecFormatter.formatUptime(packageUptime);

  String get validityDisplay =>
      PackageSpecFormatter.formatValidity(packageValidity);
}
