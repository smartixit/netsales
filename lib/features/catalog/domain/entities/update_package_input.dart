/// كائن إدخال نقي لتحديث باقة كروت قائمة (Pure Domain Update Input)
class UpdatePackageInput {
  final String? packageName;
  final String? packageColor;
  final int? packageBalance;
  final int? packageUptime;
  final int? packageValidity;
  final int? packageVoucherCount;
  final double? packageVoucherPrice;
  final double? packageDefaultCashDiscount;
  final double? packageDefaultCreditDiscount;
  final bool? status;

  const UpdatePackageInput({
    this.packageName,
    this.packageColor,
    this.packageBalance,
    this.packageUptime,
    this.packageValidity,
    this.packageVoucherCount,
    this.packageVoucherPrice,
    this.packageDefaultCashDiscount,
    this.packageDefaultCreditDiscount,
    this.status,
  });
}
