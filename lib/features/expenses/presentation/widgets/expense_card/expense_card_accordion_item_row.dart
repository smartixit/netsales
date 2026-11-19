import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';

/// سطر عرض بند المصروف داخل أكورديون البطاقة
class ExpenseCardAccordionItemRow extends StatelessWidget {
  const ExpenseCardAccordionItemRow({
    super.key,
    required this.item,
    required this.index,
  });

  final ExpenseItemEntity item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 20.r,
            height: 20.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .5),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              item.itemStatement,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.hSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.formattedAmount,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                AppSpacing.hXxs,
                Text(
                  'ر.ي',
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
