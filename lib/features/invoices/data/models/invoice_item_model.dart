import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// نموذج بيانات بند الفاتورة المحول من استجابة الـ API
class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.itemId,
    required super.invoiceId,
    required super.packageId,
    required super.voucherPrice,
    required super.voucherCount,
    super.itemDiscount = 0.0,
    required super.itemTotalAmount,
    super.packageName,
    super.packageColor,
    super.sheetSize = 0,
    super.createdAt,
    super.updatedAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    final packageData = json['package'] as Map<String, dynamic>?;

    return InvoiceItemModel(
      itemId: (json['item_id'] as num?)?.toInt() ?? 0,
      invoiceId: (json['invoice_id'] as num?)?.toInt() ?? 0,
      packageId: (json['package_id'] as num?)?.toInt() ?? 0,
      voucherPrice: (json['voucher_price'] as num?)?.toDouble() ?? 0.0,
      voucherCount: (json['voucher_count'] as num?)?.toInt() ?? 0,
      itemDiscount: (json['item_discount'] as num?)?.toDouble() ?? 0.0,
      itemTotalAmount: (json['item_total_amount'] as num?)?.toDouble() ?? 0.0,
      packageName: packageData?['package_name'] as String?,
      packageColor: packageData?['package_color'] as String?,
      sheetSize: (packageData?['package_voucher_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'invoice_id': invoiceId,
    'package_id': packageId,
    'voucher_price': voucherPrice,
    'voucher_count': voucherCount,
    'item_discount': itemDiscount,
    'item_total_amount': itemTotalAmount,
    if (packageName != null) 'package_name': packageName,
    if (packageColor != null) 'package_color': packageColor,
    'sheet_size': sheetSize,
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}
