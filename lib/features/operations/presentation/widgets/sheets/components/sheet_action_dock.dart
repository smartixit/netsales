import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// رصيف الإجراء المثبت الفاخر للنوافذ السفلية (SheetActionDock)
/// ============================================================================
/// يوفر وصولاً فورياً ودائماً لأزرار الاعتماد والإصدار مع عرض الصافي اللحظي
/// بتصميم مزدوج الطبقات (Two-Tier Executive Dock) يضمن عدم التجاوز الأفقي إطلاقاً.
class SheetActionDock extends StatelessWidget {
  final int totalCount;
  final double netAmount;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final VoidCallback onCancel;

  const SheetActionDock({
    super.key,
    required this.totalCount,
    required this.netAmount,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSelection = totalCount > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. شريط ملخص الصافي والعدد (محمي بـ Expanded لمنع التجاوز)
            Row(
              children: [
                Text(
                  hasSelection ? '$totalCount كرت محدد' : 'لم تحدد باقات بعد',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'الصافي: ',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          hasSelection
                              ? AmountFormatter.formatValue(netAmount)
                              : '0.00',
                          style: AppTypography.titleMedium.copyWith(
                            color: hasSelection ? colors.primary : colors.outline,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        AppSpacing.hXxs,
                        Text(
                          'ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // 2. أزرار الإجراء السفلية المتجاوبة تماماً
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CustomButton.outline(
                    text: 'إلغاء',
                    onPressed: onCancel,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  flex: 2,
                  child: CustomButton.primary(
                    text: actionLabel,
                    icon: actionIcon,
                    onPressed: onAction,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
