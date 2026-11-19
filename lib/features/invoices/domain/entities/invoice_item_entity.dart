import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';

/// كيان بند فاتورة مبيعات الكروت (Sale Invoice Item Entity)
///
/// يمثل بنداً مالياً معتمداً ومسجلاً رسمياً ضمن فاتورة المبيعات أو المشتريات.
/// يخضع للحسابات السيادية من الخادم ولا يحتوي على أي منطق واجهة مستخدم أو اعتماديات خارجية.
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

  /// التوصيف المزدوج الكامل للبند (الأوراق والكروت معاً)
  String get fullQuantityLabel {
    final desc = sheetDescription;
    if (sheetSize <= 0) return desc;
    return '$desc  •  $voucherCount كرت';
  }

  /// توصيف عدد الأوراق والشيتات بصيغة رقمية مقروءة
  String get formattedSheetsCount {
    if (sheetSize <= 0) return '0 ورقة';
    final sheets = voucherCount / sheetSize;
    return '${sheets.toStringAsFixed(1)} ورقة';
  }

  /// سعر الكرت المفرد منسقاً
  String get formattedVoucherPrice =>
      AmountFormatter.format(voucherPrice.toString());

  /// إجمالي البند المالي منسقاً
  String get formattedItemTotalAmount =>
      AmountFormatter.format(itemTotalAmount.toString());

  /// قيمة الخصم المالي المطبق على البند منسقة
  String get formattedDiscount =>
      AmountFormatter.format(itemDiscount.toString());

  /// هل يحتوي البند على خصم مالي معتمد
  bool get hasDiscount => itemDiscount > 0.001;

  /// إجمالي قيمة البند الإجمالية قبل الخصم
  double get grossAmount => itemTotalAmount + itemDiscount;

  /// إجمالي قيمة البند قبل الخصم منسقة
  String get formattedGrossAmount =>
      AmountFormatter.format(grossAmount.toString());
}
