import 'package:netsales/features/more/domain/entities/more_subscription_entity.dart';
import 'package:netsales/features/more/domain/entities/more_support_summary_entity.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';

/// ============================================================================
/// كائن ملخص قطاع المزيد الدوميني النقي (MoreOverviewEntity)
/// ============================================================================
/// كائن تجميعي نقي يحمل ملخصات المحفظة والاشتراكات والمصروفات والدعم الفني.
class MoreOverviewEntity {
  final MoreWalletEntity? wallet;
  final MoreSubscriptionEntity? subscription;
  final MoreSupportSummaryEntity? supportSummary;
  final double totalExpensesThisMonth;
  final int activeSessionsCount;

  const MoreOverviewEntity({
    this.wallet,
    this.subscription,
    this.supportSummary,
    this.totalExpensesThisMonth = 0.0,
    this.activeSessionsCount = 1,
  });

  @override
  String toString() =>
      'MoreOverviewEntity(wallet: $wallet, subscription: $subscription, expenses: $totalExpensesThisMonth)';
}
