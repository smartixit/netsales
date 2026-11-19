import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/cards/custom_metric_display_card.dart';

/// شريط مؤشرات ملخص المصروفات التشغيلية المعتمد على [CustomMetricDisplayCard]
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'إجمالي المصروفات',
                  value: AmountFormatter.format(totalAmount.toString()),
                  unit: 'ر.ي',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: colors.error,
                  isPrimary: true,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'عدد المصروفات',
                  value: totalCount.toString(),
                  unit: 'سند',
                  icon: Icons.receipt_long_rounded,
                  accentColor: colors.primary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,
        Row(
          children: [
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'مصروف الشهر',
                  value: AmountFormatter.format(thisMonthAmount.toString()),
                  unit: 'ر.ي',
                  icon: Icons.calendar_month_rounded,
                  accentColor: colors.warning,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'مصروف اليوم',
                  value: AmountFormatter.format(todayAmount.toString()),
                  unit: 'ر.ي',
                  icon: Icons.today_rounded,
                  accentColor: colors.success,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
