import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

class ProcurementOrderCardNetworkActions extends StatelessWidget {
  const ProcurementOrderCardNetworkActions({
    super.key,
    required this.isPending,
    required this.onDetails,
    this.onApprove,
    this.onModify,
    this.onReject,
    required this.onMoreActions,
  });

  final bool isPending;
  final VoidCallback onDetails;
  final VoidCallback? onApprove;
  final VoidCallback? onModify;
  final VoidCallback? onReject;
  final VoidCallback onMoreActions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isPending) {
      return Row(
        children: [
          if (onApprove != null)
            Expanded(
              flex: 4,
              child: CustomButton.primary(
                text: 'اعتماد الطلب',
                icon: Icons.check_circle_outline_rounded,
                size: AppButtonSize.small,
                shape: AppButtonShape.pill,
                onPressed: onApprove,
              ),
            ),
          if (onModify != null) ...[
            AppSpacing.hXs,
            Expanded(
              flex: 3,
              child: CustomButton.outline(
                text: 'تعديل',
                icon: Icons.edit_note_rounded,
                size: AppButtonSize.small,
                foregroundColor: colors.primary,
                borderColor: colors.primary.withValues(alpha: .5),
                onPressed: onModify,
              ),
            ),
          ],
          if (onReject != null) ...[
            AppSpacing.hXs,
            CustomButton.icon(
              icon: Icons.cancel_outlined,
              tooltip: 'رفض الطلب',
              dimension: 38.r,
              backgroundColor: colors.error.withValues(alpha: .08),
              foregroundColor: colors.error,
              borderColor: colors.error.withValues(alpha: .25),
              onPressed: onReject,
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

    return Row(
      children: [
        Expanded(
          child: CustomButton.primary(
            text: 'عرض تفاصيل الطلب',
            icon: Icons.chevron_right_rounded,
            iconPosition: AppButtonIconPosition.end,
            size: AppButtonSize.small,
            shape: AppButtonShape.pill,
            onPressed: onDetails,
          ),
        ),
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.more_horiz_rounded,
          tooltip: 'المزيد من الخيارات',
          size: AppButtonSize.small,
          shape: AppButtonShape.circle,
          backgroundColor: colors.surfaceContainerHigh,
          foregroundColor: colors.onSurfaceVariant,
          onPressed: onMoreActions,
        ),
      ],
    );
  }
}
