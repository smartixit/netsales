import 'package:equatable/equatable.dart';

/// بند مسعر معتمد سيادياً في عرض أسعار طلب التوريد (Server-Authoritative Quote Line)
class ProcurementQuoteLineEntity extends Equatable {
  final int packageId;
  final String packageName;
  final String? packageColor;
  final int packageVoucherCount;
  final int voucherCount;
  final double unitPrice;
  final double discountRate;
  final double effectivePrice;
  final double lineGrossTotal;
  final double lineDiscountAmount;
  final double lineNetTotal;
  final bool isCustomDiscount;
  final String? pricingToken;

  const ProcurementQuoteLineEntity({
    required this.packageId,
    required this.packageName,
    this.packageColor,
    required this.packageVoucherCount,
    required this.voucherCount,
    required this.unitPrice,
    required this.discountRate,
    required this.effectivePrice,
    required this.lineGrossTotal,
    required this.lineDiscountAmount,
    required this.lineNetTotal,
    this.isCustomDiscount = false,
    this.pricingToken,
  });

  @override
  List<Object?> get props => [
        packageId,
        packageName,
        packageColor,
        packageVoucherCount,
        voucherCount,
        unitPrice,
        discountRate,
        effectivePrice,
        lineGrossTotal,
        lineDiscountAmount,
        lineNetTotal,
        isCustomDiscount,
        pricingToken,
      ];
}

