import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ProcurementOrderCardPosActions extends StatelessWidget {
  const ProcurementOrderCardPosActions({
    super.key,
    required this.onDetails,
    this.onEdit,
    this.onCancel,
    this.onDelete,
    required this.onMoreActions,
  });

  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final VoidCallback onMoreActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: CustomButton.outline(
            text: 'عرض التفاصيل',
            icon: Icons.chevron_right_rounded,
            iconPosition: AppButtonIconPosition.end,
            size: AppButtonSize.small,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .6),
            onPressed: onDetails,
          ),
        ),
        if (onEdit != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.edit_note_rounded,
            tooltip: 'تعديل الطلب',
            dimension: 38.r,
            backgroundColor: colors.surfaceContainer,
            foregroundColor: colors.primary,
            borderColor: colors.primary.withValues(alpha: .3),
            onPressed: onEdit,
          ),
        ],
        if (onCancel != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.cancel_outlined,
            tooltip: 'إلغاء الطلب',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onCancel,
          ),
        ],
        if (onDelete != null) ...[
          AppSpacing.hXs,
          CustomButton.icon(
            icon: Icons.delete_outline_rounded,
            tooltip: 'حذف سجل الطلب',
            dimension: 38.r,
            backgroundColor: colors.error.withValues(alpha: .08),
            foregroundColor: colors.error,
            borderColor: colors.error.withValues(alpha: .25),
            onPressed: onDelete,
          ),
        ],
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.more_horiz_rounded,
          tooltip: 'المزيد من الخيارات',
          dimension: 38.r,
          backgroundColor: colors.surfaceContainer,
          foregroundColor: colors.onSurfaceVariant,
          borderColor: colors.outlineVariant.withValues(alpha: .6),
          onPressed: onMoreActions,
        ),
      ],
    );
  }
}
