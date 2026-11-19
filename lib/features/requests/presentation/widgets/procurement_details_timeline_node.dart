import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementDetailsTimelineNode extends StatelessWidget {
  const ProcurementDetailsTimelineNode({
    super.key,
    required this.title,
    required this.subtitle,
    this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.isCompleted,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final String? timestamp;
  final IconData icon;
  final Color iconColor;
  final bool isCompleted;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عمود الأيقونة والخط الرابط
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 13.r, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 38.h,
                color: isCompleted
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : colors.outlineVariant.withValues(alpha: 0.35),
              ),
          ],
        ),
        AppSpacing.hSm,

        // عمود التفاصيل
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timestamp != null && timestamp!.isNotEmpty)
                      Text(
                        timestamp!,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
