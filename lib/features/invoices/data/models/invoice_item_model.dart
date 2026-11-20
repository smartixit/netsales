import 'package:netsales/features/catalog/data/models/package_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_item_entity.dart';

/// نموذج بيانات بند فاتورة مبيعات الكروت للتحويل من وإلى JSON
class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.itemId,
    required super.invoiceId,
    required super.packageId,
    required super.voucherPrice,
    required super.voucherCount,
    super.itemDiscount = 0.0,
    required super.itemTotalAmount,
    super.createdAt,
    super.updatedAt,
    super.voucherPackage,
    super.customPackageName,
    super.customPackageColor,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    PackageModel? voucherPackage;
    String? customPackageName;
    String? customPackageColor;

    final rawPackage = json['package'] ?? json['voucher_package'];
    if (rawPackage is Map<String, dynamic>) {
      customPackageName = rawPackage['package_name'] as String?;
      customPackageColor = rawPackage['package_color'] as String?;
      try {
        voucherPackage = PackageModel.fromJson(rawPackage);
      } catch (_) {
        // إذا كان الكائن جزئياً كاسم ولون فقط نكتفي بالقيم المستخرجة
      }
    }

    return InvoiceItemModel(
      itemId: json['item_id'] as int? ?? 0,
      invoiceId: json['invoice_id'] as int? ?? 0,
      packageId: json['package_id'] as int? ?? 0,
      voucherPrice: (json['voucher_price'] as num?)?.toDouble() ?? 0.0,
      voucherCount: json['voucher_count'] as int? ?? 1,
      itemDiscount: (json['item_discount'] as num?)?.toDouble() ?? 0.0,
      itemTotalAmount: (json['item_total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      voucherPackage: voucherPackage,
      customPackageName: customPackageName ?? json['package_name'] as String?,
      customPackageColor:
          customPackageColor ?? json['package_color'] as String?,
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
    };
  }
}
