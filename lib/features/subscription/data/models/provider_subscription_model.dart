import 'package:netsales/features/subscription/domain/entities/feature_quota_item_entity.dart';
import 'package:netsales/features/subscription/domain/entities/provider_subscription_entity.dart';

/// نموذج بيانات اشتراك مزود الشبكة وحصصه من Laravel API
class ProviderSubscriptionModel {
  final int subscriptionId;
  final int networkId;
  final int planId;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final String status;
  final String? statusLabel;
  final Map<String, dynamic>? planMap;
  final List<dynamic>? consumptionsList;

  const ProviderSubscriptionModel({
    required this.subscriptionId,
    required this.networkId,
    required this.planId,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.status,
    this.statusLabel,
    this.planMap,
    this.consumptionsList,
  });

  factory ProviderSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return ProviderSubscriptionModel(
      subscriptionId: json['subscription_id'] as int? ?? 0,
      networkId: json['network_id'] as int? ?? 0,
      planId: json['plan_id'] as int? ?? 0,
      subscriptionStartDate: json['subscription_start_date']?.toString(),
      subscriptionEndDate: json['subscription_end_date']?.toString(),
      status: json['status']?.toString() ?? 'INACTIVE',
      statusLabel: json['status_label']?.toString(),
      planMap: json['plan'] is Map
          ? Map<String, dynamic>.from(json['plan'] as Map)
          : null,
      consumptionsList: json['consumptions'] is List
          ? List<dynamic>.from(json['consumptions'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'network_id': networkId,
      'plan_id': planId,
      'subscription_start_date': subscriptionStartDate,
      'subscription_end_date': subscriptionEndDate,
      'status': status,
      'status_label': statusLabel,
      if (planMap != null) 'plan': planMap,
      if (consumptionsList != null) 'consumptions': consumptionsList,
    };
  }

  /// تحويل النموذج إلى كيان الدومين النقي مع حساب الحصص والاستهلاك الفعلي
  ProviderSubscriptionEntity toEntity() {
    final plan = planMap ?? <String, dynamic>{};
    final planName = plan['plan_name']?.toString() ?? 'باقة الاشتراك';
    final planPrice = (plan['plan_price'] as num?)?.toDouble() ?? 0.0;
    final planValidity = plan['plan_validity'] as int? ?? 30;
    final planDesc = plan['plan_desc']?.toString();

    // خريطة استهلاك الميزات من الخادم: feature_id -> { consumption_value, last_consumption_at }
    final consumptionsMap = <int, Map<String, dynamic>>{};
    if (consumptionsList != null) {
      for (final item in consumptionsList!) {
        if (item is Map) {
          final fId = item['feature_id'] as int? ?? 0;
          if (fId > 0) {
            consumptionsMap[fId] = Map<String, dynamic>.from(item);
          }
        }
      }
    }

    final quotas = <FeatureQuotaItemEntity>[];
    final planFeatures = plan['plan_features'] ?? plan['features'];

    if (planFeatures is List) {
      for (final pf in planFeatures) {
        if (pf is! Map) continue;
        final pfMap = Map<String, dynamic>.from(pf);

        // قد تكون البيانات مغلفة في feature أو مباشرة
        final featureObj = pfMap['feature'] is Map
            ? Map<String, dynamic>.from(pfMap['feature'] as Map)
            : pfMap;

        final featureId =
            pfMap['feature_id'] as int? ??
            featureObj['feature_id'] as int? ??
            0;
        final rawVal =
            pfMap['plan_feature_value']?.toString() ??
            featureObj['feature_value']?.toString() ??
            '0';

        final limitVal = int.tryParse(rawVal) ?? 0;
        final isUnlimited = limitVal == -1;

        final consumptionRecord = consumptionsMap[featureId];
        final consumedValue = consumptionRecord != null
            ? (consumptionRecord['consumption_value'] as int? ?? 0)
            : 0;

        DateTime? lastConsumed;
        if (consumptionRecord?['last_consumption_at'] != null) {
          lastConsumed = DateTime.tryParse(
            consumptionRecord!['last_consumption_at'].toString(),
          );
        }

        quotas.add(
          FeatureQuotaItemEntity(
            featureId: featureId,
            featureName:
                featureObj['feature_name']?.toString() ?? 'ميزة النظام',
            featureDesc: featureObj['feature_desc']?.toString(),
            valueType: featureObj['feature_value_type']?.toString(),
            isUnlimited: isUnlimited,
            quotaLimit: limitVal,
            consumedValue: consumedValue,
            lastConsumptionAt: lastConsumed,
          ),
        );
      }
    }

    return ProviderSubscriptionEntity(
      subscriptionId: subscriptionId,
      networkId: networkId,
      planId: planId,
      planName: planName,
      planPrice: planPrice,
      planValidity: planValidity,
      planDesc: planDesc,
      startDate: subscriptionStartDate != null
          ? DateTime.tryParse(subscriptionStartDate!)
          : null,
      endDate: subscriptionEndDate != null
          ? DateTime.tryParse(subscriptionEndDate!)
          : null,
      status: status,
      statusLabel: statusLabel ?? status,
      quotas: List.unmodifiable(quotas),
    );
  }
}
