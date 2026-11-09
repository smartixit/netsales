import 'package:netsales/features/subscription/domain/entities/feature_quota_item_entity.dart';

/// كيان اشتراك مزود الشبكة السحابي (Provider Subscription Entity)
class ProviderSubscriptionEntity {
  final int subscriptionId;
  final int networkId;
  final int planId;
  final String planName;
  final double planPrice;
  final int planValidity;
  final String? planDesc;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String statusLabel;
  final List<FeatureQuotaItemEntity> quotas;

  const ProviderSubscriptionEntity({
    required this.subscriptionId,
    required this.networkId,
    required this.planId,
    required this.planName,
    required this.planPrice,
    required this.planValidity,
    this.planDesc,
    this.startDate,
    this.endDate,
    required this.status,
    required this.statusLabel,
    this.quotas = const [],
  });

  /// هل الاشتراك نشط حالياً؟
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// عدد الأيام المتبقية حتى تاريخ الانتهاء
  int get remainingDays {
    if (endDate == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  /// هل توجد أي حصص نفدت؟
  bool get hasExhaustedQuotas => quotas.any((q) => q.isExhausted);

  /// هل توجد أي حصص على وشك النفاد؟
  bool get hasNearExhaustionQuotas => quotas.any((q) => q.isNearExhaustion);
}
