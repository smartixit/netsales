import 'package:netsales/features/operations/domain/entities/request_pricing_preview_entity.dart';

/// ============================================================================
/// نماذج بيانات معاينة التسعير والتعديل السيادي (Request Pricing Preview Model)
/// ============================================================================

class RequestPreviewItemModel extends RequestPreviewItemEntity {
  const RequestPreviewItemModel({
    required super.packageId,
    required super.packageName,
    super.packageCategory,
    required super.voucherCount,
    required super.voucherPrice,
    required super.itemDiscount,
    required super.itemTotalAmount,
    required super.grossTotalAmount,
    required super.discountAmount,
    required super.source,
    super.pricingToken,
    required super.changeType,
    super.originalVoucherCount,
  });

  factory RequestPreviewItemModel.fromJson(Map<String, dynamic> json) {
    return RequestPreviewItemModel(
      packageId: _toInt(json['package_id']),
      packageName: json['package_name'] as String? ?? '',
      packageCategory: json['package_category'] as String?,
      voucherCount: _toInt(json['voucher_count']),
      voucherPrice: _toDouble(json['voucher_price']),
      itemDiscount: _toDouble(json['item_discount']),
      itemTotalAmount: _toDouble(json['item_total_amount']),
      grossTotalAmount: _toDouble(json['gross_total_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      source: json['source'] as String? ?? 'ORIGINAL',
      pricingToken: json['pricing_token'] as String?,
      changeType: json['change_type'] as String? ?? 'UNCHANGED',
      originalVoucherCount: json['original_voucher_count'] != null
          ? _toInt(json['original_voucher_count'])
          : null,
    );
  }

  Map<String, dynamic> toRequestPayload() {
    return {
      'package_id': packageId,
      'voucher_count': voucherCount,
      if (pricingToken != null && pricingToken!.isNotEmpty)
        'pricing_token': pricingToken,
    };
  }
}

class RequestPreviewRemovedItemModel extends RequestPreviewRemovedItemEntity {
  const RequestPreviewRemovedItemModel({
    required super.packageId,
    required super.packageName,
    required super.originalVoucherCount,
    required super.voucherPrice,
    required super.itemDiscount,
    required super.originalItemTotal,
  });

  factory RequestPreviewRemovedItemModel.fromJson(Map<String, dynamic> json) {
    return RequestPreviewRemovedItemModel(
      packageId: _toInt(json['package_id']),
      packageName: json['package_name'] as String? ?? '',
      originalVoucherCount: _toInt(json['original_voucher_count']),
      voucherPrice: _toDouble(json['voucher_price']),
      itemDiscount: _toDouble(json['item_discount']),
      originalItemTotal: _toDouble(json['original_item_total']),
    );
  }
}

class RequestPricingPreviewModel extends RequestPricingPreviewEntity {
  const RequestPricingPreviewModel({
    required super.requestId,
    required super.requestUuid,
    required super.originalTotalAmount,
    required super.previewTotalAmount,
    required super.grossTotalAmount,
    required super.totalDiscountAmount,
    required super.saleType,
    required super.saleTypeLabel,
    required super.hasModifications,
    required super.items,
    required super.removedItems,
  });

  factory RequestPricingPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<RequestPreviewItemModel> parsedItems;
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map(RequestPreviewItemModel.fromJson)
          .toList();
    } else {
      parsedItems = const [];
    }

    final rawRemoved = json['removed_items'];
    final List<RequestPreviewRemovedItemModel> parsedRemoved;
    if (rawRemoved is List) {
      parsedRemoved = rawRemoved
          .whereType<Map<String, dynamic>>()
          .map(RequestPreviewRemovedItemModel.fromJson)
          .toList();
    } else {
      parsedRemoved = const [];
    }

    return RequestPricingPreviewModel(
      requestId: _toInt(json['request_id']),
      requestUuid: json['request_uuid'] as String? ?? '',
      originalTotalAmount: _toDouble(json['original_total_amount']),
      previewTotalAmount: _toDouble(json['preview_total_amount']),
      grossTotalAmount: _toDouble(json['gross_total_amount']),
      totalDiscountAmount: _toDouble(json['total_discount_amount']),
      saleType: json['sale_type'] as String? ?? 'CASH',
      saleTypeLabel: json['sale_type_label'] as String? ?? 'نقد',
      hasModifications: json['has_modifications'] as bool? ?? false,
      items: parsedItems,
      removedItems: parsedRemoved,
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

