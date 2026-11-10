/// كيان الخصم الفعلي المطبق لنقطة بيع على باقة معينة (Effective Package Discount Entity)
/// يعكس القيم المالية المعتمدة سيادياً من خادم Laravel (Server-Authoritative Values §34)
class EffectivePackageDiscountEntity {
  /// نسبة الخصم النقدي %
  final double discountCash;

  /// نسبة الخصم الآجل %
  final double discountCredit;

  /// هل هذا الخصم مخصص واستثنائي لنقطة البيع (true) أم هو الخصم العام الافتراضي للباقة (false)؟
  final bool isCustom;

  /// السعر الأساسي للكرت قبل الخصم
  final double originalPackagePrice;

  /// السعر الفعلي النقدي المعتمد بعد الخصم
  final double effectiveCashPrice;

  /// السعر الفعلي الآجل المعتمد بعد الخصم
  final double effectiveCreditPrice;

  /// مقدار الوفر النقدي لكل كرت
  final double cashSavings;

  /// مقدار الوفر الآجل لكل كرت
  final double creditSavings;

  const EffectivePackageDiscountEntity({
    required this.discountCash,
    required this.discountCredit,
    required this.isCustom,
    required this.originalPackagePrice,
    required this.effectiveCashPrice,
    required this.effectiveCreditPrice,
    required this.cashSavings,
    required this.creditSavings,
  });
}

