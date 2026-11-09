import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';

class RequestModificationPreviewModel extends RequestModificationPreviewEntity {
  const RequestModificationPreviewModel({
    required super.requestId,
    super.requestUuid,
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

  factory RequestModificationPreviewModel.fromJson(Map<String, dynamic> json) {
    return RequestModificationPreviewModel(
      requestId: _requiredInt(json, 'request_id'),
      requestUuid: json['request_uuid'] as String?,
      originalTotalAmount: _requiredDouble(json, 'original_total_amount'),
      previewTotalAmount: _requiredDouble(json, 'preview_total_amount'),
      grossTotalAmount: _requiredDouble(json, 'gross_total_amount'),
      totalDiscountAmount: _requiredDouble(json, 'total_discount_amount'),
      saleType: _requiredString(json, 'sale_type'),
      saleTypeLabel: _requiredString(json, 'sale_type_label'),
      hasModifications: json['has_modifications'] == true,
      items: _requiredList(
        json,
        'items',
      ).map(_parsePreviewItem).toList(growable: false),
      removedItems: _requiredList(
        json,
        'removed_items',
      ).map(_parseRemovedItem).toList(growable: false),
    );
  }

  static RequestModificationPreviewItemEntity _parsePreviewItem(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid request modification preview item.');
    }

    return RequestModificationPreviewItemEntity(
      packageId: _requiredInt(value, 'package_id'),
      packageName: _requiredString(value, 'package_name'),
      packageCategory: value['package_category'] as String?,
      voucherCount: _requiredInt(value, 'voucher_count'),
      voucherPrice: _requiredDouble(value, 'voucher_price'),
      itemDiscount: _requiredDouble(value, 'item_discount'),
      itemTotalAmount: _requiredDouble(value, 'item_total_amount'),
      grossTotalAmount: _requiredDouble(value, 'gross_total_amount'),
      discountAmount: _requiredDouble(value, 'discount_amount'),
      source: _requiredString(value, 'source'),
      pricingToken: value['pricing_token'] as String?,
      changeType: _requiredString(value, 'change_type'),
      originalVoucherCount: _nullableInt(value, 'original_voucher_count'),
    );
  }

  static RequestModificationRemovedItemEntity _parseRemovedItem(dynamic value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid removed request item.');
    }

    return RequestModificationRemovedItemEntity(
      packageId: _requiredInt(value, 'package_id'),
      packageName: _requiredString(value, 'package_name'),
      originalVoucherCount: _requiredInt(value, 'original_voucher_count'),
      voucherPrice: _requiredDouble(value, 'voucher_price'),
      itemDiscount: _requiredDouble(value, 'item_discount'),
      originalItemTotal: _requiredDouble(value, 'original_item_total'),
    );
  }

  static List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! List) {
      throw FormatException('Missing or invalid "$key" in preview response.');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Missing or invalid "$key" in preview response.');
  }

  static int? _nullableInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Invalid "$key" in preview response.');
  }

  static double _requiredDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    throw FormatException('Missing or invalid "$key" in preview response.');
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('Missing or invalid "$key" in preview response.');
  }
}
