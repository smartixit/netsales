import 'package:netsales/features/invoices/data/models/invoice_item_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// نموذج بيانات فاتورة مبيعات ومشتريات الكروت للتحويل من وإلى JSON
class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.invoiceId,
    required super.networkId,
    required super.posId,
    super.requestId,
    super.requestUuid,
    super.invoiceUuid,
    super.saleTypeRaw,
    super.saleTypeLabel,
    required super.invoiceTotalAmount,
    super.paidAmount = 0.0,
    super.remainingAmount = 0.0,
    super.paymentStatusRaw,
    super.paymentStatusLabel,
    super.isFullyPaid = false,
    super.invoiceDate,
    super.createdBy,
    super.networkName,
    super.networkPhoneNumber,
    super.networkLogo,
    super.posName,
    super.posPhoneNumber,
    super.posLogo,
    super.createdByName,
    super.items = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String? networkName;
    String? networkPhone;
    String? networkLogo;
    if (json['network'] is Map<String, dynamic>) {
      final net = json['network'] as Map<String, dynamic>;
      networkName = net['network_name'] as String?;
      networkPhone = net['network_phone_number'] as String?;
      networkLogo = (net['network_profile_logo'] ?? net['logo_url']) as String?;
    }

    String? posName;
    String? posPhone;
    String? posLogo;
    if (json['pos'] is Map<String, dynamic>) {
      final p = json['pos'] as Map<String, dynamic>;
      posName = p['pos_name'] as String?;
      posPhone = p['pos_phone_number'] as String?;
      posLogo = (p['pos_profile_logo'] ?? p['logo_url']) as String?;
    }

    String? createdByName;
    if (json['created_by_user'] is Map<String, dynamic>) {
      createdByName =
          (json['created_by_user'] as Map<String, dynamic>)['user_full_name']
              as String?;
    }

    final itemsList = <InvoiceItemModel>[];
    if (json['items'] is List) {
      for (final rawItem in json['items'] as List) {
        if (rawItem is Map<String, dynamic>) {
          itemsList.add(InvoiceItemModel.fromJson(rawItem));
        }
      }
    }

    return InvoiceModel(
      invoiceId: json['invoice_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      requestId: json['request_id'] as int?,
      requestUuid: json['request_uuid'] as String?,
      invoiceUuid: json['invoice_uuid'] as String?,
      saleTypeRaw: json['sale_type'] as String?,
      saleTypeLabel: json['sale_type_label'] as String?,
      invoiceTotalAmount:
          (json['invoice_total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatusRaw: json['payment_status'] as String?,
      paymentStatusLabel: json['payment_status_label'] as String?,
      isFullyPaid: json['is_fully_paid'] as bool? ?? false,
      invoiceDate: json['invoice_date'] as String?,
      createdBy: json['created_by'] as int?,
      networkName: networkName ?? json['network_name'] as String?,
      networkPhoneNumber:
          networkPhone ?? json['network_phone_number'] as String?,
      networkLogo: networkLogo ?? json['network_logo'] as String?,
      posName: posName ?? json['pos_name'] as String?,
      posPhoneNumber: posPhone ?? json['pos_phone_number'] as String?,
      posLogo: posLogo ?? json['pos_logo'] as String?,
      createdByName: createdByName,
      items: itemsList,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'network_id': networkId,
      'pos_id': posId,
      if (requestId != null) 'request_id': requestId,
      if (invoiceUuid != null) 'invoice_uuid': invoiceUuid,
      if (saleTypeRaw != null) 'sale_type': saleTypeRaw,
      'invoice_total_amount': invoiceTotalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      if (paymentStatusRaw != null) 'payment_status': paymentStatusRaw,
      'is_fully_paid': isFullyPaid,
      'items': items.map((i) => (i as InvoiceItemModel).toJson()).toList(),
    };
  }
}
