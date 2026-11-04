/// كيان الخصم الفعلي المعتمد سيادياً من الخادم
class EffectiveDiscountEntity {
  final int networkId;
  final int posId;
  final int packageId;
  final String source; // 'CUSTOM' or 'DEFAULT'
  final double discountCash;
  final double discountCredit;
  final double originalPrice;
  final double effectiveCashPrice;
  final double effectiveCreditPrice;
  final double cashSavings;
  final double creditSavings;

  const EffectiveDiscountEntity({
    required this.networkId,
    required this.posId,
    required this.packageId,
    required this.source,
    required this.discountCash,
    required this.discountCredit,
    required this.originalPrice,
    required this.effectiveCashPrice,
    required this.effectiveCreditPrice,
    required this.cashSavings,
    required this.creditSavings,
  });

  bool get isCustom => source == 'CUSTOM';
}

