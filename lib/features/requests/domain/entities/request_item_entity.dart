import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// كيان بند طلب الكروت (Voucher Request Item Entity)
class RequestItemEntity {
  final int itemId;
  final int requestId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? createdAt;
  final String? updatedAt;
  final PackageEntity? voucherPackage;

  const RequestItemEntity({
    required this.itemId,
    required this.requestId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    this.itemDiscount = 0.0,
    required this.itemTotalAmount,
    this.createdAt,
    this.updatedAt,
    this.voucherPackage,
  });

  /// سعة الورقة/الشيت بالكروت
  int get sheetSize =>
      (voucherPackage?.packageVoucherCount ?? 0) > 0
          ? voucherPackage!.packageVoucherCount
          : 100;

  /// عدد الأوراق المحسوبة للبند
  double get sheetsCount =>
      sheetSize > 0 ? (voucherCount / sheetSize) : 0.0;

  /// صيغة نصية منسقة لعدد الأوراق
  String get formattedSheetsCount =>
      sheetsCount.truncateToDouble() == sheetsCount
          ? sheetsCount.toInt().toString()
          : sheetsCount.toStringAsFixed(1);

  /// وصف التوزيع الورقي (شيت + كروت متبقية)
  String get sheetDescription =>
      VoucherSheetCalculator.describe(voucherCount, sheetSize);

  /// المبلغ الإجمالي قبل الخصم
  double get grossAmount => voucherPrice * voucherCount;

  /// هل يحتوي البند على خصم؟
  bool get hasDiscount => itemDiscount > 0;

  /// هل الخصم مخصص لنقطة البيع؟
  bool get isCustomDiscount =>
      voucherPackage?.procurementIsCustomDiscount == true;

  /// اسم الباقة التوريدية
  String get packageName =>
      voucherPackage?.packageName ?? 'باقة كروت #$packageId';
}
