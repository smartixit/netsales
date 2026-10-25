import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// عنصر قائمة تفاعلي لقطاع المزيد (MoreMenuTile)
/// ============================================================================
/// يمثل عنصراً قياسياً تفاعلياً مع ارتداد فيزيائي وأيقونة لونية مخصصة.
class MoreMenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const MoreMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        child: Row(
          children: [
            // أيقونة البند
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.r,
                ),
              ),
            ),

            AppSpacing.hMd,

            // العنوان والوصف
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // العنصر اللاحق (Badge أو سهم الانتقال لليمين في RTL)
            trailing ??
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
          ],
        ),
      ),
    );
  }
}
