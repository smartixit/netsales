import 'package:equatable/equatable.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_line_entity.dart';

/// عرض أسعار رسمي معتمد سيادياً من الخادم لطلب التوريد (ProcurementQuoteEntity)
class ProcurementQuoteEntity extends Equatable {
  final int networkId;
  final int posId;
  final SaleType saleType;
  final String saleTypeLabel;
  final double grossTotal;
  final double discountTotal;
  final double netTotal;
  final String currency;
  final String pricingToken;
  final DateTime? expiresAt;
  final List<ProcurementQuoteLineEntity> items;

  const ProcurementQuoteEntity({
    required this.networkId,
    required this.posId,
    required this.saleType,
    required this.saleTypeLabel,
    required this.grossTotal,
    required this.discountTotal,
    required this.netTotal,
    required this.currency,
    required this.pricingToken,
    this.expiresAt,
    required this.items,
  });

  /// العثور على البند المسعر لباقة محددة
  ProcurementQuoteLineEntity? findLine(int packageId) {
    try {
      return items.firstWhere((line) => line.packageId == packageId);
    } catch (_) {
      return null;
    }
  }

  /// نسبة الخصم الإجمالية لكامل الطلب
  double get totalDiscountPercentage {
    if (grossTotal <= 0) return 0.0;
    return (discountTotal / grossTotal) * 100.0;
  }

  @override
  List<Object?> get props => [
        networkId,
        posId,
        saleType,
        saleTypeLabel,
        grossTotal,
        discountTotal,
        netTotal,
        currency,
        pricingToken,
        expiresAt,
        items,
      ];
}

