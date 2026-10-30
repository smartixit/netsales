import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/more/domain/entities/expense_entity.dart';

/// ============================================================================
/// بطاقة قيد مصروف تشغيلي واحد داخل سجل النفقات (ExpenseHistoryCard)
/// ============================================================================
/// عرض للقراءة فقط: كافة القيم المالية (المبلغ، التاريخ، اسم المُدخل) مصدرها
/// الخادم، ولا يُجرى أي حساب مالي على مستوى الواجهة.
class ExpenseHistoryCard extends StatelessWidget {
  const ExpenseHistoryCard({super.key, required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expenseDate = expense.expenseDate;
    final dateLabel = expenseDate != null
        ? DateFormatter.date(expenseDate)
        : 'اليوم';
    final createdBy = expense.createdByName ?? 'الإدارة';

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: AppElevation.level1(context),
      ),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: colors.error,
              size: 20.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'قيد مصروف #${expense.expenseUuid}',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXs,
                Text(
                  '$dateLabel • $createdBy',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ${AmountFormatter.formatValue(expense.expenseTotalAmount)} ر.ي',
            style: AppTypography.titleSmall.copyWith(
              color: colors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
