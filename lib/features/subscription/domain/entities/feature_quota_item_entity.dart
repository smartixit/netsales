/// كيان حصة الميزة واستهلاكها الفعلي (Feature Quota Item Entity)
class FeatureQuotaItemEntity {
  final int featureId;
  final String featureName;
  final String? featureDesc;
  final String? valueType;
  final bool isUnlimited;
  final int quotaLimit;
  final int consumedValue;
  final DateTime? lastConsumptionAt;

  const FeatureQuotaItemEntity({
    required this.featureId,
    required this.featureName,
    this.featureDesc,
    this.valueType,
    required this.isUnlimited,
    required this.quotaLimit,
    required this.consumedValue,
    this.lastConsumptionAt,
  });

  /// الحصة المتبقية محلياً
  int get remainingValue {
    if (isUnlimited) return -1;
    final diff = quotaLimit - consumedValue;
    return diff < 0 ? 0 : diff;
  }

  /// نسبة الاستهلاك من 0.0 إلى 1.0
  double get percentage {
    if (isUnlimited) return 0.0;
    if (quotaLimit <= 0) return 1.0;
    final ratio = consumedValue / quotaLimit;
    return ratio.clamp(0.0, 1.0);
  }

  /// هل الحصة نفدت بالكامل؟
  bool get isExhausted => !isUnlimited && consumedValue >= quotaLimit;

  /// هل الحصة على وشك النفاد (استهلاك 80% فأكثر)؟
  bool get isNearExhaustion =>
      !isUnlimited && !isExhausted && percentage >= 0.8;
}
