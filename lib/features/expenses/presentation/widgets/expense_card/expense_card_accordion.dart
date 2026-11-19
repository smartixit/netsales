import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_entity.dart';
import 'package:netsales/features/expenses/presentation/widgets/expense_card/expense_card_accordion_item_row.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// أكورديون تفاعلي يعرض بنود المصروف التشغيلي
class ExpenseCardAccordion extends StatelessWidget {
  const ExpenseCardAccordion({
    super.key,
    required this.expense,
    required this.isExpanded,
    required this.onToggle,
  });

  final ExpenseEntity expense;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = expense.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // زر التوسيع / الطي
        CustomInteractiveBounce(
          onTap: onToggle,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isExpanded ? 'إخفاء تفاصيل البنود' : 'عرض تفاصيل البنود (${items.length})',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
                AppSpacing.hXs,
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16.r,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),

        // المحتوى الموسع
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            margin: EdgeInsets.only(top: 6.h),
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: .06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        'لا توجد بنود مسجلة لهذا المصروف',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ...items.asMap().entries.map(
                        (entry) => ExpenseCardAccordionItemRow(
                          item: entry.value,
                          index: entry.key + 1,
                        ),
                      ),
              ],
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
