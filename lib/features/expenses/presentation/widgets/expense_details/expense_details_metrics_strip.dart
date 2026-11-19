import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/widgets/cards/custom_metric_card_data.dart';
import 'package:netsales/widgets/cards/custom_metric_display_card.dart';
import 'package:netsales/widgets/indicators/custom_amount_to_words_banner.dart';

/// شريط المؤشرات المالية والتشغيلية المعتمد في شاشة تفاصيل المصروف التشغيلي
class ExpenseDetailsMetricsStrip extends StatelessWidget {
  const ExpenseDetailsMetricsStrip({super.key, required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── شبكة البطاقات الإحصائية الأربع ──
        Row(
          children: [
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'إجمالي المصروف',
                  value: AmountFormatter.format(expense.expenseTotalAmount.toString()),
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
                  label: 'عدد البنود',
                  value: expense.itemsCount.toString(),
                  unit: 'بند',
                  icon: Icons.layers_outlined,
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
                  label: 'عدد المرفقات',
                  value: expense.attachmentsCount.toString(),
                  unit: 'ملف',
                  icon: Icons.attach_file_rounded,
                  accentColor: colors.secondary,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomMetricDisplayCard(
                data: CustomMetricCardData(
                  label: 'التاريخ المعتمد',
                  value: expense.formattedExpenseDate,
                  icon: Icons.calendar_today_rounded,
                  accentColor: colors.tertiary,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vSm,

        // شريط تفقيط المبلغ المالي المعتمد
        CustomAmountToWordsBanner(
          amount: expense.expenseTotalAmount,
          currencyCode: 'YER',
        ),
      ],
    );
  }
}
