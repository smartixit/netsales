/// ============================================================================
/// كائن اشتراك النظام الدوميني النقي (MoreSubscriptionEntity)
/// ============================================================================
/// كائن دوميني نقي يمثل حالة اشتراك المزود في خطة النظام السحابية.
class MoreSubscriptionEntity {
  final int subscriptionId;
  final String planName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final String statusLabel;

  const MoreSubscriptionEntity({
    required this.subscriptionId,
    required this.planName,
    this.startDate,
    this.endDate,
    required this.status,
    required this.statusLabel,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  int get daysRemaining {
    if (endDate == null) return 0;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoreSubscriptionEntity &&
          runtimeType == other.runtimeType &&
          subscriptionId == other.subscriptionId;

  @override
  int get hashCode => subscriptionId.hashCode;

  @override
  String toString() =>
      'MoreSubscriptionEntity(id: $subscriptionId, plan: $planName, days: $daysRemaining)';
}
