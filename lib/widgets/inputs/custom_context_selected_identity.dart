import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';

/// بطاقة هوية العنصر المختار حالياً للمكون العام CustomContextSelector
class CustomContextSelectedIdentity extends StatelessWidget {
  const CustomContextSelectedIdentity({
    super.key,
    required this.name,
    required this.detail,
    required this.initial,
    this.logoUrl,
    required this.accent,
    required this.isExpanded,
    required this.canExpand,
    required this.isReadOnly,
    required this.readOnlyBadgeText,
  });

  final String name;
  final String detail;
  final String initial;
  final String? logoUrl;
  final Color accent;
  final bool isExpanded;
  final bool canExpand;
  final bool isReadOnly;
  final String readOnlyBadgeText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainer.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .55)),
      ),
      child: Row(
        children: [
          CustomAvatarBadge(
            imageUrl: logoUrl,
            initials: initial,
            size: AvatarBadgeSize.sm,
            customDimension: 40.r,
            gradientColors: [accent, accent.withValues(alpha: .75)],
            hasPulse: false,
            borderRadius: BorderRadius.circular(12.r),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLarge.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 11.5.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isReadOnly) ...[
            AppSpacing.hXs,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: .6),
                ),
              ),
              child: Text(
                readOnlyBadgeText,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ] else if (canExpand) ...[
            AppSpacing.hXs,
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: accent,
              size: 22.r,
            ),
          ],
        ],
      ),
    );
  }
}
