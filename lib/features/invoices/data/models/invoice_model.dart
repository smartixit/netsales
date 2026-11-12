import 'package:netsales/features/invoices/data/models/invoice_item_model.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// نموذج بيانات فاتورة المبيعات (Sale Invoice DTO)
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
    super.networkLogoUrl,
    super.posName,
    super.posLogoUrl,
    super.posPhoneNumber,
    super.items = const [],
    super.createdAt,
    super.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String? netName;
    if (json['network'] is Map<String, dynamic>) {
      netName =
          (json['network'] as Map<String, dynamic>)['network_name'] as String?;
    }

    String? networkLogoUrl;
    if (json['network'] is Map) {
      final networkObj = Map<String, dynamic>.from(json['network'] as Map);
      networkLogoUrl = networkObj['network_profile_logo']?.toString();
    }

    String? pName;
    String? pPhone;
    String? posLogoUrl;
    if (json['pos'] is Map<String, dynamic>) {
      final posObj = json['pos'] as Map<String, dynamic>;
      pName = posObj['pos_name'] as String?;
      pPhone = posObj['pos_phone_number'] as String?;
      posLogoUrl = posObj['pos_profile_logo']?.toString();
    }

    final rawItems = json['items'];
    final parsedItems = <InvoiceItemModel>[];
    if (rawItems is List) {
      for (final itm in rawItems) {
        if (itm is Map<String, dynamic>) {
          parsedItems.add(InvoiceItemModel.fromJson(itm));
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
      networkName: netName,
      networkLogoUrl: networkLogoUrl,
      posName: pName,
      posLogoUrl: posLogoUrl,
      posPhoneNumber: pPhone,
      items: parsedItems,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      'network_id': networkId,
      'pos_id': posId,
      'request_id': requestId,
      'request_uuid': requestUuid,
      'invoice_uuid': invoiceUuid,
      'sale_type': saleTypeRaw,
      'sale_type_label': saleTypeLabel,
      'invoice_total_amount': invoiceTotalAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,
      'payment_status': paymentStatusRaw,
      'payment_status_label': paymentStatusLabel,
      'is_fully_paid': isFullyPaid,
      'invoice_date': invoiceDate,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
