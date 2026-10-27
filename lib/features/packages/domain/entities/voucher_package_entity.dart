import 'package:netsales/core/utils/voucher_sheet_calculator.dart';

/// ============================================================================
/// كيان باقة كروت الإنترنت (VoucherPackageEntity)
/// ============================================================================
/// كائن نقي يمثل بيانات باقة الكروت، الأسعار، الحصص، الصلاحية، ونسب الخصم
/// الافتراضية، خالٍ تماماً من أي اعتماديات خارجية أو منطق تسلسل JSON.
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

  const VoucherPackageEntity({
    required this.packageId,
    required this.networkId,
    required this.packageName,
    this.packageColor,
    this.packageBalance,
    this.packageUptime,
    this.packageValidity,
    this.packageVoucherCount = 51,
    required this.packageVoucherPrice,
    required this.packageDefaultCashDiscount,
    required this.packageDefaultCreditDiscount,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.networkName,
  });

  /// فحص تفعيل الباقة
  bool get isActive => status;

  /// قيمة الخصم الافتراضي بالريال للدفع النقدي
  double get defaultCashDiscountAmount =>
      (packageVoucherPrice * packageDefaultCashDiscount) / 100;

  /// سعر الشراء الافتراضي الصافي لنقطة البيع بالدفع النقدي
  double get defaultEffectiveCashPrice =>
      packageVoucherPrice - defaultCashDiscountAmount;

  /// قيمة الخصم الافتراضي بالريال للدفع الآجل
  double get defaultCreditDiscountAmount =>
      (packageVoucherPrice * packageDefaultCreditDiscount) / 100;

  /// سعر الشراء الافتراضي الصافي لنقطة البيع بالدفع الآجل
  double get defaultEffectiveCreditPrice =>
      packageVoucherPrice - defaultCreditDiscountAmount;

  /// عدد كروت نصف الورقة مقرباً للأعلى (مثال: 51 -> 26)
  int get halfSheetVoucherCount =>
      VoucherSheetCalculator.halfSheetCards(packageVoucherCount);

  /// حساب عدد الكروت الفعلي لعدد محدد من الأوراق (مثال: 1.5 ورقة -> 77 كرت)
  int vouchersForSheets(double sheets) =>
      VoucherSheetCalculator.cardsForSheets(sheets, packageVoucherCount);

  /// التوصيف النصي المقروء لكمية الكروت (مثال: 77 -> "ورقة ونصف")
  String describeSheetQuantity(int cards) =>
      VoucherSheetCalculator.describe(cards, packageVoucherCount);

  /// كبسولات الأوراق السريعة المقترحة للباقة
  List<VoucherSheetPreset> get sheetPresets =>
      VoucherSheetCalculator.getPresets(packageVoucherCount);

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
    );
  }
}
