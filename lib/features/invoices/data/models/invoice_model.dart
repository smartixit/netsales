import 'package:netsales/features/invoices/data/models/invoice_item_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// نموذج بيانات الفاتورة المحول من استجابة الـ API
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
    super.createdByName,
    super.networkName,
    super.networkLogoUrl,
    super.networkPhoneNumber,
    super.networkEmail,
    super.networkAddress,
    super.posName,
    super.posLogoUrl,
    super.posPhoneNumber,
    super.posEmail,
    super.posAddress,
    super.items = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final networkData = json['network'] as Map<String, dynamic>?;
    final posData = json['pos'] as Map<String, dynamic>?;
    final createdByUserData = json['created_by_user'] as Map<String, dynamic>?;
    final rawItems = json['items'] as List<dynamic>? ?? const [];

    final parsedItems = rawItems
        .whereType<Map<String, dynamic>>()
        .map(InvoiceItemModel.fromJson)
        .toList(growable: false);

    final total = (json['invoice_total_amount'] as num?)?.toDouble() ?? 0.0;
    final paid = (json['paid_amount'] as num?)?.toDouble() ?? 0.0;
    final remaining = (json['remaining_amount'] as num?)?.toDouble() ?? 0.0;
    final isFullyPaid =
        json['is_fully_paid'] as bool? ?? (remaining <= 0.001 && total > 0);

    return InvoiceModel(
      invoiceId: (json['invoice_id'] as num?)?.toInt() ?? 0,
      networkId: (json['network_id'] as num?)?.toInt() ?? 0,
      posId: (json['pos_id'] as num?)?.toInt() ?? 0,
      requestId: (json['request_id'] as num?)?.toInt(),
      requestUuid: json['request_uuid'] as String?,
      invoiceUuid: json['invoice_uuid'] as String?,
      saleTypeRaw: json['sale_type'] as String?,
      saleTypeLabel: json['sale_type_label'] as String?,
      invoiceTotalAmount: total,
      paidAmount: paid,
      remainingAmount: remaining,
      paymentStatusRaw: json['payment_status'] as String?,
      paymentStatusLabel: json['payment_status_label'] as String?,
      isFullyPaid: isFullyPaid,
      invoiceDate: json['invoice_date'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdByName: createdByUserData?['user_full_name'] as String?,
      networkName: networkData?['network_name'] as String?,
      networkLogoUrl: networkData?['network_profile_logo'] as String?,
      networkPhoneNumber: networkData?['network_phone_number'] as String?,
      networkEmail: networkData?['network_email'] as String?,
      networkAddress: networkData?['network_address'] as String?,
      posName: posData?['pos_name'] as String?,
      posLogoUrl: posData?['pos_profile_logo'] as String?,
      posPhoneNumber: posData?['pos_phone_number'] as String?,
      posEmail: posData?['pos_email'] as String?,
      posAddress: posData?['pos_address'] as String?,
      items: parsedItems,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'invoice_id': invoiceId,
    'network_id': networkId,
    'pos_id': posId,
    if (requestId != null) 'request_id': requestId,
    if (requestUuid != null) 'request_uuid': requestUuid,
    if (invoiceUuid != null) 'invoice_uuid': invoiceUuid,
    if (saleTypeRaw != null) 'sale_type': saleTypeRaw,
    if (saleTypeLabel != null) 'sale_type_label': saleTypeLabel,
    'invoice_total_amount': invoiceTotalAmount,
    'paid_amount': paidAmount,
    'remaining_amount': remainingAmount,
    if (paymentStatusRaw != null) 'payment_status': paymentStatusRaw,
    if (paymentStatusLabel != null) 'payment_status_label': paymentStatusLabel,
    'is_fully_paid': isFullyPaid,
    if (invoiceDate != null) 'invoice_date': invoiceDate,
    if (createdBy != null) 'created_by': createdBy,
    if (createdByName != null) 'created_by_name': createdByName,
    if (networkName != null) 'network_name': networkName,
    if (networkLogoUrl != null) 'network_logo_url': networkLogoUrl,
    if (networkPhoneNumber != null)
      'network_phone_number': networkPhoneNumber,
    if (networkEmail != null) 'network_email': networkEmail,
    if (networkAddress != null) 'network_address': networkAddress,
    if (posName != null) 'pos_name': posName,
    if (posLogoUrl != null) 'pos_logo_url': posLogoUrl,
    if (posPhoneNumber != null) 'pos_phone_number': posPhoneNumber,
    if (posEmail != null) 'pos_email': posEmail,
    if (posAddress != null) 'pos_address': posAddress,
    'items': items
        .whereType<InvoiceItemModel>()
        .map((e) => e.toJson())
        .toList(),
    if (createdAt != null) 'created_at': createdAt,
    if (updatedAt != null) 'updated_at': updatedAt,
  };
}
