import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';

/// ============================================================================
/// نموذج بيانات طلب توريد الكروت (VoucherRequestModel)
/// ============================================================================
/// يرث إجبارياً من الكيان الدوميني ويتحمل مسؤولية تسلسل الـ JSON حصراً.
class VoucherRequestModel extends VoucherRequestEntity {
  const VoucherRequestModel({
    required super.requestId,
    required super.networkId,
    required super.posId,
    required super.requestUuid,
    required super.saleType,
    required super.saleTypeLabel,
    required super.requestTotalAmount,
    super.requestDate,
    required super.status,
    required super.statusLabel,
    required super.createdBy,
    super.reviewedBy,
    super.reviewDate,
    super.requestNote,
    super.createdAt,
    super.updatedAt,
    super.networkName,
    super.posName,
    super.posCode,
    super.items,
  });

  factory VoucherRequestModel.fromJson(Map<String, dynamic> json) {
    final networkData = json['network'] as Map<String, dynamic>?;
    final posData = json['pos'] as Map<String, dynamic>?;

    final rawItems = json['items'];
    final List<VoucherRequestItemModel> parsedItems;
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map(VoucherRequestItemModel.fromJson)
          .toList();
    } else {
      parsedItems = const [];
    }

    return VoucherRequestModel(
      requestId: _toInt(json['request_id']),
      networkId: _toInt(json['network_id']),
      posId: _toInt(json['pos_id']),
      requestUuid: json['request_uuid'] as String? ?? '',
      saleType: json['sale_type'] as String? ?? 'CASH',
      saleTypeLabel: json['sale_type_label'] as String? ?? 'نقدي',
      requestTotalAmount: _toDouble(json['request_total_amount']),
      requestDate: json['request_date'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      statusLabel: json['status_label'] as String? ?? 'قيد الانتظار',
      createdBy: _toInt(json['created_by']),
      reviewedBy: json['reviewed_by'] != null ? _toInt(json['reviewed_by']) : null,
      reviewDate: json['review_date'] as String?,
      requestNote: json['request_note'] as String?,
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
      'request_id': requestId,
      'network_id': networkId,
      'pos_id': posId,
      'sale_type': saleType,
      'request_total_amount': requestTotalAmount,
      'status': status,
      'request_note': requestNote,
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

/// نموذج بيانات بند طلب توريد الكروت
class VoucherRequestItemModel extends VoucherRequestItemEntity {
  const VoucherRequestItemModel({
    required super.itemId,
    required super.requestId,
    required super.packageId,
    required super.voucherPrice,
    required super.voucherCount,
    required super.itemDiscount,
    required super.itemTotalAmount,
    super.packageName,
    super.createdAt,
  });

  factory VoucherRequestItemModel.fromJson(Map<String, dynamic> json) {
    final packageData = json['package'] as Map<String, dynamic>?;

    return VoucherRequestItemModel(
      itemId: _toInt(json['item_id']),
      requestId: _toInt(json['request_id']),
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
