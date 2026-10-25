import 'package:netsales/features/more/data/models/more_subscription_model.dart';
import 'package:netsales/features/more/data/models/more_support_summary_model.dart';
import 'package:netsales/features/more/data/models/more_wallet_model.dart';
import 'package:netsales/features/more/domain/entities/more_overview_entity.dart';

/// ============================================================================
/// نموذج بيانات ملخص قطاع المزيد (MoreOverviewModel)
/// ============================================================================
/// يرث بالضرورة من الكيان الدوميني [MoreOverviewEntity] طبقاً لقواعد Clean Architecture.
class MoreOverviewModel extends MoreOverviewEntity {
  const MoreOverviewModel({
    super.wallet,
    super.subscription,
    super.supportSummary,
    super.totalExpensesThisMonth = 0.0,
    super.activeSessionsCount = 1,
  });

  factory MoreOverviewModel.fromJson(Map<String, dynamic> json) {
    final rawExpenses = json['total_expenses_this_month'] ?? json['expenses_month'] ?? 0.0;
    final expenses = (rawExpenses is num)
        ? rawExpenses.toDouble()
        : double.tryParse(rawExpenses.toString()) ?? 0.0;

    final walletJson = json['wallet'] is Map ? json['wallet'] as Map<String, dynamic> : null;
    final subJson = json['subscription'] is Map
        ? json['subscription'] as Map<String, dynamic>
        : null;
    final supportJson = json['support_summary'] is Map
        ? json['support_summary'] as Map<String, dynamic>
        : null;

    return MoreOverviewModel(
      wallet: walletJson != null ? MoreWalletModel.fromJson(walletJson) : null,
      subscription:
          subJson != null ? MoreSubscriptionModel.fromJson(subJson) : null,
      supportSummary: supportJson != null
          ? MoreSupportSummaryModel.fromJson(supportJson)
          : null,
      totalExpensesThisMonth: expenses,
      activeSessionsCount:
          (json['active_sessions_count'] ?? json['sessions_count'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (wallet is MoreWalletModel) 'wallet': (wallet as MoreWalletModel).toJson(),
      if (subscription is MoreSubscriptionModel)
        'subscription': (subscription as MoreSubscriptionModel).toJson(),
      if (supportSummary is MoreSupportSummaryModel)
        'support_summary': (supportSummary as MoreSupportSummaryModel).toJson(),
      'total_expenses_this_month': totalExpensesThisMonth,
      'active_sessions_count': activeSessionsCount,
    };
  }
}
