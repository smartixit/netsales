import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

/// بطاقة تفاعلية عامة وموحدة للاختيارات والإجراءات (CustomActionCard)
/// مغلّفة بارتداد فيزيائي ناعم وظلال قياسية من AppElevation.level2.
/// صالحة للاستخدام في شاشات الترحيب، اختيار الحساب، الباقات، والإعدادات.
class CustomActionCard extends StatelessWidget {
  const CustomActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    this.badgeText,
    this.showTrailing = true,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;
  final String? badgeText;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: AppElevation.level2(context),
        ),
        child: Row(
          children: [
            // أيقونة الإجراء الدائرية مع حدود ناعمة
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: accentColor, size: 26.r),
            ),
            AppSpacing.hMd,

            // النصوص التوضيحية
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (badgeText != null) ...[
                        AppSpacing.hSm,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppTypography.labelSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppSpacing.vXs,
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // سهم الانتقال
            if (showTrailing) ...[
              AppSpacing.hSm,
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
