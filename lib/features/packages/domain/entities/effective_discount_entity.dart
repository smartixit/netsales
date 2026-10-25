/// ============================================================================
/// كيان الخصم الفعلي المطبق (EffectiveDiscountEntity)
/// ============================================================================
/// كائن نقي يمثل نتيجة احتساب الخصم الفعلي لنقطة بيع على باقة معينة
/// (سواء كان خصماً مخصصاً استثنائياً أو خصم الباقة الافتراضي).
class EffectiveDiscountEntity {
  final double discountCash;
  final double discountCredit;
  final bool isCustom;

  const EffectiveDiscountEntity({
    required this.discountCash,
    required this.discountCredit,
    required this.isCustom,
  });

  /// الحصول على نسبة الخصم بناء على نوع الدفع
  double getDiscountRate({required bool isCredit}) =>
      isCredit ? discountCredit : discountCash;

  /// احتساب السعر الفعلي الصافي
  double calculateEffectivePrice(
    double originalPrice, {
    required bool isCredit,
  }) {
    final rate = getDiscountRate(isCredit: isCredit);
    final discountAmount = (originalPrice * rate) / 100;
    return originalPrice - discountAmount;
  }

  /// احتساب مقدار الوفر المالي / ربح نقطة البيع
  double calculateSavings(
    double originalPrice, {
    required bool isCredit,
  }) {
    final rate = getDiscountRate(isCredit: isCredit);
    return (originalPrice * rate) / 100;
  }
}
