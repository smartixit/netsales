import 'package:netsales/features/requests/data/models/request_item_model.dart';
import 'package:netsales/features/requests/data/models/request_modification_summary_model.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// نموذج بيانات طلب الكروت والتوريد للتحويل من وإلى JSON
class RequestModel extends RequestEntity {
  const RequestModel({
    required super.requestId,
    required super.networkId,
    required super.posId,
    super.requestUuid,
    super.saleTypeRaw,
    super.saleTypeLabel,
    required super.requestTotalAmount,
    super.requestDate,
    super.statusRaw,
    super.statusLabel,
    super.createdBy,
    super.reviewedBy,
    super.reviewDate,
    super.requestNote,
    super.invoiceId,
    super.invoiceUuid,
    super.networkName,
    super.networkPhone,
    super.networkLogo,
    super.posName,
    super.posPhone,
    super.posLogo,
    super.createdByName,
    super.reviewedByName,
    super.items = const [],
    super.modificationSummary,
    super.createdAt,
    super.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    // استخراج اسم الشبكة ونقطة البيع وجهات الاتصال من العلاقات المحملة مسبقاً إن وجدت
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

    String? reviewedByName;
    if (json['reviewed_by_user'] is Map<String, dynamic>) {
      reviewedByName =
          (json['reviewed_by_user'] as Map<String, dynamic>)['user_full_name']
              as String?;
    }

    // استخراج البنود
    final itemsList = <RequestItemModel>[];
    if (json['items'] is List) {
      for (final rawItem in json['items'] as List) {
        if (rawItem is Map<String, dynamic>) {
          itemsList.add(RequestItemModel.fromJson(rawItem));
        }
      }
    }

    final rawSummary = json['modifications_summary'];
    if (rawSummary != null && rawSummary is! Map) {
      throw const FormatException('ملخص تعديلات الطلب يجب أن يكون كائناً.');
    }
    final modificationSummary = rawSummary is Map
        ? RequestModificationSummaryModel.fromJson(
            Map<String, dynamic>.from(rawSummary),
          )
        : null;

    return RequestModel(
      requestId: json['request_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      requestUuid: json['request_uuid'] as String?,
      saleTypeRaw: json['sale_type'] as String?,
      saleTypeLabel: json['sale_type_label'] as String?,
      requestTotalAmount:
          (json['request_total_amount'] as num?)?.toDouble() ?? 0.0,
      requestDate: json['request_date'] as String?,
      statusRaw: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      createdBy: json['created_by'] as int?,
      reviewedBy: json['reviewed_by']?.toString(),
      reviewDate: json['review_date'] as String?,
      requestNote: json['request_note'] as String?,
      invoiceId: json['invoice_id'] as int?,
      invoiceUuid: json['invoice_uuid'] as String?,
      networkName: networkName,
      networkPhone: networkPhone,
      networkLogo: networkLogo,
      posName: posName,
      posPhone: posPhone,
      posLogo: posLogo,
      createdByName: createdByName,
      reviewedByName: reviewedByName,
      items: itemsList,
      modificationSummary: modificationSummary,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_id': networkId,
      'pos_id': posId,
      if (saleTypeRaw != null) 'sale_type': saleTypeRaw,
      if (requestNote != null) 'request_note': requestNote,
      'items': items
          .map(
            (i) => {'package_id': i.packageId, 'voucher_count': i.voucherCount},
          )
          .toList(),
    };
  }
}
