import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';

class ProcurementQuoteLineModel extends ProcurementQuoteLineEntity {
  const ProcurementQuoteLineModel({
    required super.packageId,
    required super.packageName,
    super.packageColor,
    required super.packageVoucherCount,
    required super.voucherCount,
    required super.unitPrice,
    required super.discountRate,
    required super.effectivePrice,
    required super.lineGrossTotal,
    required super.lineDiscountAmount,
    required super.lineNetTotal,
    super.isCustomDiscount,
    super.pricingToken,
  });

  factory ProcurementQuoteLineModel.fromJson(Map<String, dynamic> json) {
    return ProcurementQuoteLineModel(
      packageId: json['package_id'] as int? ?? 0,
      packageName: json['package_name'] as String? ?? '',
      packageColor: json['package_color'] as String?,
      packageVoucherCount: json['package_voucher_count'] as int? ?? 1,
      voucherCount: json['voucher_count'] as int? ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      discountRate: (json['discount_rate'] as num?)?.toDouble() ?? 0.0,
      effectivePrice: (json['effective_price'] as num?)?.toDouble() ?? 0.0,
      lineGrossTotal: (json['line_gross_total'] as num?)?.toDouble() ?? 0.0,
      lineDiscountAmount: (json['line_discount_amount'] as num?)?.toDouble() ?? 0.0,
      lineNetTotal: (json['line_net_total'] as num?)?.toDouble() ?? 0.0,
      isCustomDiscount: json['is_custom_discount'] as bool? ?? false,
      pricingToken: json['pricing_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'package_name': packageName,
      'package_color': packageColor,
      'package_voucher_count': packageVoucherCount,
      'voucher_count': voucherCount,
      'unit_price': unitPrice,
      'discount_rate': discountRate,
      'effective_price': effectivePrice,
      'line_gross_total': lineGrossTotal,
      'line_discount_amount': lineDiscountAmount,
      'line_net_total': lineNetTotal,
      'is_custom_discount': isCustomDiscount,
      'pricing_token': pricingToken,
    };
  }
}

