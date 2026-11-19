import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/expenses/domain/entities/expense_item_entity.dart';

/// بطاقة بند المصروف داخل قائمة تفاصيل سند الصرف
class ExpenseDetailsItemCard extends StatelessWidget {
  const ExpenseDetailsItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  final ExpenseItemEntity item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: .28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: .03),
        ),
        child: Row(
          children: [
            // شارة الترقيم
            Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: colors.error.withValues(alpha: .30),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '#${index + 1}',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            AppSpacing.hSm,

            // بيان البند
            Expanded(
              child: Text(
                item.itemStatement,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppSpacing.hSm,

            // مبلغ البند المالي
            Flexible(
              child: FittedBox(
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
            ),
          ],
        ),
      ),
    );
  }
}
