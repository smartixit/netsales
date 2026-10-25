import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';

/// ============================================================================
/// نموذج بيانات اشتراك النظام (MoreSubscriptionModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [MoreSubscriptionEntity] طبقاً لقواعد Clean Architecture.
class MoreSubscriptionModel extends MoreSubscriptionEntity {
  const MoreSubscriptionModel({
    required super.subscriptionId,
    required super.planName,
    super.startDate,
    super.endDate,
    required super.status,
    required super.statusLabel,
  });

  factory MoreSubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.tryParse(value.toString());
      } catch (_) {
        return null;
      }
    }

    final plan = json['plan'] is Map ? json['plan'] as Map<String, dynamic> : null;
    final planName = plan?['name']?.toString() ??
        plan?['plan_name']?.toString() ??
        json['plan_name']?.toString() ??
        'الخطة الافتراضية';

    return MoreSubscriptionModel(
      subscriptionId: (json['subscription_id'] ?? json['id'] ?? 0) as int,
      planName: planName,
      startDate: parseDate(json['subscription_start_date'] ?? json['start_date']),
      endDate: parseDate(json['subscription_end_date'] ?? json['end_date']),
      status: (json['status'] ?? 'ACTIVE').toString(),
      statusLabel: json['status_label']?.toString() ??
          ((json['status'] == 'ACTIVE') ? 'نشط وسارٍ' : 'منتهٍ'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'plan_name': planName,
      if (startDate != null) 'subscription_start_date': startDate!.toIso8601String(),
      if (endDate != null) 'subscription_end_date': endDate!.toIso8601String(),
      'status': status,
      'status_label': statusLabel,
    };
  }
}
