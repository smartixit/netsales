import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط إجراءات موحد لعضويات Network وPOS مع اختلاف النصوص فقط.
class MembershipCardActionBar extends StatelessWidget {
  const MembershipCardActionBar({
    super.key,
    required this.isNetworkView,
    required this.isActive,
    required this.isOwner,
    required this.onDetails,
    required this.onMoreActions,
    this.onChangeRole,
    this.onToggleStatus,
    this.onRemove,
  });

  final bool isNetworkView;
  final bool isActive;
  final bool isOwner;
  final VoidCallback onDetails;
  final VoidCallback onMoreActions;
  final VoidCallback? onChangeRole;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (isOwner) {
      return Row(children: [
        Expanded(child: CustomButton.outline(
          text: 'عرض الملف التعريفي',
          icon: Icons.person_outline_rounded,
          size: AppButtonSize.small,
          foregroundColor: colors.primary,
          borderColor: colors.primary.withValues(alpha: .5),
          onPressed: onDetails,
        )),
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
      ]);
    }

    return Row(children: [
      if (onChangeRole != null)
        Expanded(flex: 4, child: CustomButton.outline(
          text: isNetworkView ? 'تغيير الدور' : 'تعديل الدور',
          icon: Icons.manage_accounts_outlined,
          size: AppButtonSize.small,
          foregroundColor: colors.primary,
          borderColor: colors.primary.withValues(alpha: .5),
          onPressed: onChangeRole,
        )),
      if (onToggleStatus != null) ...[
        AppSpacing.hXs,
        CustomButton.icon(
          icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
          tooltip: isActive
              ? (isNetworkView ? 'تجميد العضوية' : 'تجميد الحساب')
              : (isNetworkView ? 'تنشيط العضوية' : 'تنشيط الحساب'),
          dimension: 38.r,
          backgroundColor: isActive ? colors.warning.withValues(alpha: .08) : colors.success.withValues(alpha: .08),
          foregroundColor: isActive ? colors.warning : colors.success,
          borderColor: (isActive ? colors.warning : colors.success).withValues(alpha: .3),
          onPressed: onToggleStatus,
        ),
      ],
      if (onRemove != null) ...[
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.person_remove_outlined,
          tooltip: isNetworkView ? 'إزالة العضو' : 'إزالة من نقطة البيع',
          dimension: 38.r,
          backgroundColor: colors.error.withValues(alpha: .08),
          foregroundColor: colors.error,
          borderColor: colors.error.withValues(alpha: .25),
          onPressed: onRemove,
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
    ]);
  }
}
