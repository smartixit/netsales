import 'package:netsales/core/utils/voucher_sheet_calculator.dart';

/// كيان بند فاتورة مبيعات الكروت (Sale Invoice Item Entity)
class InvoiceItemEntity {
  final int itemId;
  final int invoiceId;
  final int packageId;
  final double voucherPrice;
  final int voucherCount;
  final double itemDiscount;
  final double itemTotalAmount;
  final String? packageName;
  final String? packageColor;
  final int sheetSize;
  final String? createdAt;
  final String? updatedAt;

  const InvoiceItemEntity({
    required this.itemId,
    required this.invoiceId,
    required this.packageId,
    required this.voucherPrice,
    required this.voucherCount,
    this.itemDiscount = 0.0,
    required this.itemTotalAmount,
    this.packageName,
    this.packageColor,
    this.sheetSize = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// التوصيف اللغوي الفصيح لكمية الكروت والأوراق وفق محرك النظام المركزي
  String get sheetDescription {
    if (sheetSize <= 0) return '$voucherCount كرت';
    return VoucherSheetCalculator.describe(voucherCount, sheetSize);
  }

  /// التوصيف المزدوج الكامل للبند (الأوراق والكروت)
  String get fullQuantityLabel {
    final desc = sheetDescription;
    if (sheetSize <= 0) return desc;
    return '$desc  •  $voucherCount كرت';
  }
}
