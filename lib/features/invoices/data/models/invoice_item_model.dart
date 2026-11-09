import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// نموذج بيانات بند فاتورة المبيعات (Sale Invoice Item DTO)
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
    super.createdAt,
    super.updatedAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    String? pkgName;
    String? pkgColor;
    if (json['package'] is Map<String, dynamic>) {
      final pkg = json['package'] as Map<String, dynamic>;
      pkgName = pkg['package_name'] as String?;
      pkgColor = pkg['package_color'] as String?;
    }

    return InvoiceItemModel(
      itemId: json['item_id'] as int? ?? 0,
      invoiceId: json['invoice_id'] as int? ?? 0,
      packageId: json['package_id'] as int? ?? 0,
      voucherPrice: (json['voucher_price'] as num?)?.toDouble() ?? 0.0,
      voucherCount: (json['voucher_count'] as num?)?.toInt() ?? 0,
      itemDiscount: (json['item_discount'] as num?)?.toDouble() ?? 0.0,
      itemTotalAmount: (json['item_total_amount'] as num?)?.toDouble() ?? 0.0,
      packageName: pkgName,
      packageColor: pkgColor,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'invoice_id': invoiceId,
      'package_id': packageId,
      'voucher_price': voucherPrice,
      'voucher_count': voucherCount,
      'item_discount': itemDiscount,
      'item_total_amount': itemTotalAmount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
