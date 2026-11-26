import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/expenses/domain/entities/new_expense_item_input_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';

/// بطاقة عرض بند المصروف المضاف داخل النموذج (ExpenseFormItemCard)
///
/// مكون عرض نقي مستلهم من بطاقة البند في فواتير قيد:
/// - يعرض رقم البند وبيانه والمبلغ الصافي بشكل أنيق ومضغوط.
/// - النقر على البطاقة يفتح ورقة التعديل السفلية.
/// - يدعم السحب للحذف (Dismissible) مع تأكيد عبر [CustomDialog.danger] أو زر الإزالة المباشر.
class ExpenseFormItemCard extends StatelessWidget {
  const ExpenseFormItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onRemove,
  });

  final NewExpenseItemInputEntity item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dismissible(
      key: ValueKey('expense_item_${index}_${item.itemStatement}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await HapticFeedback.mediumImpact();
        return await CustomDialog.show(
          type: DialogType.danger,
          title: 'تأكيد حذف البند',
          message: 'هل تريد حذف البند "${item.itemStatement}"؟',
          confirmLabel: 'حذف',
          cancelLabel: 'إلغاء',
        );
      },
      onDismissed: (_) => onRemove(),
      background: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Icon(Icons.delete_rounded, color: colors.onError),
      ),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: AppElevation.level1(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.itemStatement,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          AppSpacing.hXs,
                          Icon(
                            Icons.edit_outlined,
                            size: 14.r,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'اضغط لتعديل البيان أو المبلغ',
                        style: AppTypography.caption.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AmountFormatter.formatValue(item.itemAmount),
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'ر.ي',
                      style: AppTypography.caption.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                AppSpacing.hXs,
                CustomButton.icon(
                  icon: Icons.delete_outline_rounded,
                  size: AppButtonSize.small,
                  shape: AppButtonShape.circle,
                  backgroundColor: colors.error.withValues(alpha: 0.08),
                  foregroundColor: colors.error,
                  tooltip: 'حذف البند',
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
