import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_avatar_badge.dart';
import 'package:netsales/widgets/inputs/custom_context_option.dart';

/// سطر عرض خيار الهوية في قائمة الخيارات للمكون العام CustomContextSelector
class CustomContextOptionTile extends StatelessWidget {
  const CustomContextOptionTile({
    super.key,
    required this.option,
    required this.accent,
  });

  final CustomContextOption option;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: option.selected
            ? accent.withValues(alpha: .08)
            : colors.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: option.selected
              ? accent.withValues(alpha: .55)
              : colors.outlineVariant.withValues(alpha: .45),
          width: option.selected ? 1.25 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: option.onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 9.h,
            ),
            child: Row(
              children: [
                CustomAvatarBadge(
                  imageUrl: option.logoUrl,
                  initials: option.initial,
                  size: AvatarBadgeSize.sm,
                  customDimension: 34.r,
                  gradientColors: [accent, accent.withValues(alpha: .75)],
                  hasPulse: false,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: option.selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        option.detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hXs,
                Container(
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: option.selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: option.selected
                          ? accent
                          : colors.outlineVariant.withValues(alpha: .8),
                      width: 1.5,
                    ),
                  ),
                  child: option.selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 14.r,
                          color: colors.onPrimary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
