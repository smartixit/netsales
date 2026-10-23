import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';

/// ============================================================================
/// نموذج بيانات فاتورة المبيعات (SaleInvoiceModel)
/// ============================================================================
/// يرث إجبارياً من الكيان الدوميني ويتحمل مسؤولية تسلسل الـ JSON حصراً.
class SaleInvoiceModel extends SaleInvoiceEntity {
  const SaleInvoiceModel({
    required super.invoiceId,
    required super.networkId,
    required super.posId,
    required super.invoiceUuid,
    required super.saleType,
    required super.saleTypeLabel,
    required super.invoiceTotalAmount,
    required super.paidAmount,
    required super.remainingAmount,
    required super.paymentStatus,
    required super.paymentStatusLabel,
    required super.isFullyPaid,
    super.invoiceDate,
    required super.createdBy,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.posName,
    super.posCode,
    super.items,
  });

  factory SaleInvoiceModel.fromJson(Map<String, dynamic> json) {
    // استخراج بيانات العلاقات المضمنة بأمان
    final networkData = json['network'] as Map<String, dynamic>?;
    final posData = json['pos'] as Map<String, dynamic>?;

    final rawItems = json['items'];
    final List<SaleInvoiceItemModel> parsedItems;
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map(SaleInvoiceItemModel.fromJson)
          .toList();
    } else {
      parsedItems = const [];
    }

    return SaleInvoiceModel(
      invoiceId: _toInt(json['invoice_id']),
      networkId: _toInt(json['network_id']),
      posId: _toInt(json['pos_id']),
      invoiceUuid: json['invoice_uuid'] as String? ?? '',
      saleType: json['sale_type'] as String? ?? 'CASH',
      saleTypeLabel: json['sale_type_label'] as String? ?? 'نقدي',
      invoiceTotalAmount: _toDouble(json['invoice_total_amount']),
      paidAmount: _toDouble(json['paid_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),
      paymentStatus: json['payment_status'] as String? ?? 'UNPAID',
      paymentStatusLabel: json['payment_status_label'] as String? ?? 'غير مسدد',
      isFullyPaid: json['is_fully_paid'] as bool? ?? false,
      invoiceDate: json['invoice_date'] as String?,
      createdBy: _toInt(json['created_by']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      networkName: networkData?['network_name'] as String?,
      posName: posData?['pos_name'] as String?,
      posCode: posData?['pos_code'] as String?,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'network_id': networkId,
      'pos_id': posId,
      'sale_type': saleType,
      'invoice_total_amount': invoiceTotalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'payment_status': paymentStatus,
      'invoice_date': invoiceDate,
    };
  }

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}

/// نموذج بيانات بند الفاتورة
class SaleInvoiceItemModel extends SaleInvoiceItemEntity {
  const SaleInvoiceItemModel({
    required super.itemId,
    required super.invoiceId,
    required super.packageId,
    required super.voucherPrice,
    required super.voucherCount,
    required super.itemDiscount,
    required super.itemTotalAmount,
    super.packageName,
    super.createdAt,
  });

  factory SaleInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    final packageData = json['package'] as Map<String, dynamic>?;

    return SaleInvoiceItemModel(
      itemId: _toInt(json['item_id']),
      invoiceId: _toInt(json['invoice_id']),
      packageId: _toInt(json['package_id']),
      voucherPrice: _toDouble(json['voucher_price']),
      voucherCount: _toInt(json['voucher_count']),
      itemDiscount: _toDouble(json['item_discount']),
      itemTotalAmount: _toDouble(json['item_total_amount']),
      packageName: packageData?['package_name'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
