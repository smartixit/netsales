import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة الإجراء السريع المستقلة لنقطة البيع (PosQuickActionCard)
/// منسقة وفق المعمارية القيادية الفاخرة الموحدة لمساحات العمل
class PosQuickActionCard extends StatelessWidget {
  const PosQuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: CustomSurfaceCard(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(icon, color: colors.primary, size: 20.r),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.r,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
            AppSpacing.vMd,
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
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
    );
  }
}
