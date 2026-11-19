import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_metric_column.dart';

/// شريط قياسات المبالغ والبنود والمرفقات الموحد لبطاقة المصروف التشغيلي
class ExpenseCardMetricsBar extends StatelessWidget {
  const ExpenseCardMetricsBar({super.key, required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .30),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // 1. عدد البنود
          Expanded(
            flex: 2,
            child: ExpenseCardMetricColumn(
              label: 'البنود',
              value: expense.itemsCount.toString(),
              unit: 'بند',
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),

          Container(
            width: 1,
            height: 26.h,
            color: colors.outlineVariant.withValues(alpha: .35),
          ),

          // 2. عدد المرفقات
          Expanded(
            flex: 2,
            child: ExpenseCardMetricColumn(
              label: 'المرفقات',
              value: expense.attachmentsCount.toString(),
              unit: 'ملف',
            ),
          ),

          Container(
            width: 1,
            height: 26.h,
            color: colors.outlineVariant.withValues(alpha: .35),
          ),

          // 3. إجمالي المصروف
          Expanded(
            flex: 4,
            child: ExpenseCardMetricColumn(
              label: 'إجمالي الصرف',
              value: expense.formattedTotalAmount,
              unit: 'YER',
              accentColor: colors.error,
              crossAxisAlignment: CrossAxisAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}
