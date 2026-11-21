import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة المؤشر التنفيذي الفاخر لمركز الإشعارات (NotificationKpiCard)
///
/// مصممة بأسلوب VIP مع زجاجية داكنة وظلال ناعمة وإضاءة محيطية عند التحديد.
class NotificationKpiCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const NotificationKpiCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.6)
                : colors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة ملونة داخل دائرة ناعمة
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.r),
            ),
            SizedBox(width: 10.w),

            // العنوان والعدد
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? color : colors.onSurface,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
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
