import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// شريط إجراءات موحد لعلاقة الشريك في منظوري Network وPOS.
class CommercialPartnerActionBar extends StatelessWidget {
  const CommercialPartnerActionBar({
    super.key,
    required this.isNetworkView,
    required this.isActive,
    required this.onViewDetails,
    required this.onMoreActions,
    this.onToggleStatus,
    this.onDelete,
  });

  final bool isNetworkView;
  final bool isActive;
  final VoidCallback onViewDetails;
  final VoidCallback onMoreActions;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(children: [
      Expanded(child: CustomButton.outline(
        text: isNetworkView ? 'ملف نقطة البيع' : 'ملف المزود',
        icon: isNetworkView ? Icons.storefront_rounded : Icons.hub_rounded,
        size: AppButtonSize.small,
        foregroundColor: colors.primary,
        borderColor: colors.primary.withValues(alpha: .6),
        onPressed: onViewDetails,
      )),
      if (onToggleStatus != null) ...[
        AppSpacing.hXs,
        CustomButton.icon(
          icon: isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
          tooltip: isActive ? 'تجميد الارتباط التجاري' : 'تنشيط الارتباط التجاري',
          dimension: 38.r,
          backgroundColor: isActive ? colors.warning.withValues(alpha: .1) : colors.success.withValues(alpha: .1),
          foregroundColor: isActive ? colors.warning : colors.success,
          borderColor: (isActive ? colors.warning : colors.success).withValues(alpha: .3),
          onPressed: onToggleStatus,
        ),
      ],
      if (onDelete != null) ...[
        AppSpacing.hXs,
        CustomButton.icon(
          icon: Icons.link_off_rounded,
          tooltip: isNetworkView ? 'فك الارتباط التجاري' : 'فك الارتباط بمزود الشبكة',
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
    ]);
  }
}
