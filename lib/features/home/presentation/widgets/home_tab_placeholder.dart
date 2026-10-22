import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ============================================================================
/// ودجت التبويب المؤقتة الأنيقة (HomeTabPlaceholder)
/// ============================================================================
/// تُعرض داخل تبويبات HomeLayout لحين استكمال شريحة كل وحدة تالية في الخطة.
class HomeTabPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const HomeTabPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                  width: 1.w,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 36.r,
                  color: colors.primary,
                ),
              ),
            ),
            AppSpacing.vMd,
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vXs,
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
