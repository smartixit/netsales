import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/requests/data/models/procurement_quote_line_model.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';

class ProcurementQuoteModel extends ProcurementQuoteEntity {
  const ProcurementQuoteModel({
    required super.networkId,
    required super.posId,
    required super.saleType,
    required super.saleTypeLabel,
    required super.grossTotal,
    required super.discountTotal,
    required super.netTotal,
    required super.currency,
    required super.pricingToken,
    super.expiresAt,
    required super.items,
  });

  factory ProcurementQuoteModel.fromJson(Map<String, dynamic> json) {
    final rawSaleType = json['sale_type']?.toString() ?? 'CASH';
    final parsedSaleType = rawSaleType.toUpperCase() == 'CREDIT'
        ? SaleType.credit
        : SaleType.cash;

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((it) => ProcurementQuoteLineModel.fromJson(it as Map<String, dynamic>))
        .toList(growable: false);

    DateTime? expires;
    if (json['expires_at'] != null) {
      expires = DateTime.tryParse(json['expires_at'].toString());
    }

    return ProcurementQuoteModel(
      networkId: json['network_id'] as int? ?? 0,
      posId: json['pos_id'] as int? ?? 0,
      saleType: parsedSaleType,
      saleTypeLabel: json['sale_type_label'] as String? ?? (parsedSaleType == SaleType.cash ? 'نقدي' : 'آجل'),
      grossTotal: (json['gross_total'] as num?)?.toDouble() ?? 0.0,
      discountTotal: (json['discount_total'] as num?)?.toDouble() ?? 0.0,
      netTotal: (json['net_total'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'YER',
      pricingToken: json['pricing_token'] as String? ?? '',
      expiresAt: expires,
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'network_id': networkId,
      'pos_id': posId,
      'sale_type': saleType.wireValue,
      'sale_type_label': saleTypeLabel,
      'gross_total': grossTotal,
      'discount_total': discountTotal,
      'net_total': netTotal,
      'currency': currency,
      'pricing_token': pricingToken,
      'expires_at': expiresAt?.toIso8601String(),
      'items': items
          .map((it) => (it is ProcurementQuoteLineModel ? it : ProcurementQuoteLineModel(
                packageId: it.packageId,
                packageName: it.packageName,
                packageColor: it.packageColor,
                packageVoucherCount: it.packageVoucherCount,
                voucherCount: it.voucherCount,
                unitPrice: it.unitPrice,
                discountRate: it.discountRate,
                effectivePrice: it.effectivePrice,
                lineGrossTotal: it.lineGrossTotal,
                lineDiscountAmount: it.lineDiscountAmount,
                lineNetTotal: it.lineNetTotal,
                isCustomDiscount: it.isCustomDiscount,
                pricingToken: it.pricingToken,
              )).toJson())
          .toList(),
    };
  }
}

