import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// كيان بند فاتورة مبيعات الكروت (Sale Invoice Item Entity)
///
/// يمثل سطراً تعاقدياً معتمداً ومحسوباً سيادياً داخل الفاتورة.
class InvoiceItemEntity {
  final int itemId;
  final int invoiceId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? createdAt;
  final String? updatedAt;
  final PackageEntity? voucherPackage;
  final String? customPackageName;
  final String? customPackageColor;

  const InvoiceItemEntity({
    required this.itemId,
    required this.invoiceId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    this.itemDiscount = 0.0,
    required this.itemTotalAmount,
    this.createdAt,
    this.updatedAt,
    this.voucherPackage,
    this.customPackageName,
    this.customPackageColor,
  });

  /// سعة الورقة/الشيت بالكروت
  int get sheetSize {
    final count = voucherPackage?.packageVoucherCount ?? 0;
    return count > 0 ? count : 100;
  }

  /// عدد الأوراق المحسوبة للبند
  double get sheetsCount => sheetSize > 0 ? (voucherCount / sheetSize) : 0.0;

  /// صيغة نصية منسقة لعدد الأوراق
  String get formattedSheetsCount =>
      sheetsCount.truncateToDouble() == sheetsCount
      ? sheetsCount.toInt().toString()
      : sheetsCount.toStringAsFixed(1);

  /// وصف التوزيع الورقي (شيت + كروت متبقية)
  String get sheetDescription =>
      VoucherSheetCalculator.describe(voucherCount, sheetSize);

  /// التوصيف الكامل المزدوج للبند (الأوراق والكروت)
  String get fullQuantityLabel => '$sheetDescription  •  $voucherCount كرت';

  /// المبلغ الإجمالي قبل الخصم
  double get grossAmount => voucherPrice * voucherCount;

  /// هل يحتوي البند على خصم؟
  bool get hasDiscount => itemDiscount > 0;

  /// اسم الباقة التوريدية
  String get packageName =>
      customPackageName ??
      voucherPackage?.packageName ??
      'باقة كروت #$packageId';

  /// لون تمييز الباقة التوريدية
  String? get packageColor =>
      customPackageColor ?? voucherPackage?.packageColor;
}
