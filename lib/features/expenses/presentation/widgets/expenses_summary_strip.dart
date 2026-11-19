import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط مؤشرات ملخص المصروفات التشغيلية المعتمد على [CustomStatusSummaryStrip]
class ExpensesSummaryStrip extends StatelessWidget {
  const ExpensesSummaryStrip({
    super.key,
    required this.totalCount,
    required this.totalAmount,
    required this.thisMonthAmount,
    required this.todayAmount,
    this.isLoading = false,
  });

  final int totalCount;
  final double totalAmount;
  final double thisMonthAmount;
  final double todayAmount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      CustomKpiCardData(
        label: 'عدد المصروفات',
        count: totalCount,
        statusKey: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: 'إجمالي المصروفات',
        count: totalAmount.toInt(),
        statusKey: 'TOTAL_AMOUNT',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: colors.error,
      ),
      CustomKpiCardData(
        label: 'مصروف الشهر',
        count: thisMonthAmount.toInt(),
        statusKey: 'THIS_MONTH',
        icon: Icons.calendar_month_rounded,
        accentColor: colors.warning,
      ),
      CustomKpiCardData(
        label: 'مصروف اليوم',
        count: todayAmount.toInt(),
        statusKey: 'TODAY',
        icon: Icons.today_rounded,
        accentColor: colors.success,
      ),
    ];

    return CustomStatusSummaryStrip(
      cards: cards,
      isLoading: isLoading,
    );
  }
}
