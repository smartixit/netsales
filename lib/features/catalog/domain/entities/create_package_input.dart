/// كائن إدخال نقي لإنشاء باقة كروت إنترنت (Pure Domain Creation Input)
class CreatePackageInput {
  final int networkId;
  final String packageName;
  final String? packageColor;
  final int packageBalance; // بالبايت عبر PackageSpecFormatter
  final int? packageUptime; // بالدقائق عبر PackageSpecFormatter
  final int? packageValidity; // بالدقائق عبر PackageSpecFormatter
  final int packageVoucherCount;
  final double packageVoucherPrice;
  final double packageDefaultCashDiscount;
  final double packageDefaultCreditDiscount;
  final bool status;

  const CreatePackageInput({
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
    required this.status,
  });
}
