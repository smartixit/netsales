import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// بطاقة الترويسة القيادية الموحدة لصفحات المنصة (Executive Page Hero Card)
///
/// تجسد المعايير البصرية العليا لمنصة NetSales:
/// - خلفية بتدرج لوني تنفيذي فاخر وتأثيرات ضوئية خافتة.
/// - إطار وظلال زمردية/ذهبية دافئة مستمدة حصراً من نظام [AppColors].
/// - أيقونة ثلاثية الأبعاد بإطار زجاجي ناعم مع دعم الشارات والأزرار التفاعلية.
/// - حماية كاملة للنصوص والتجاوب عبر مختلف أحجام الشاشات.
class CustomPageHeroCard extends StatelessWidget {
  const CustomPageHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.receipt_long_rounded,
    this.action,
    this.badge,
    this.gradient,
    this.iconColor,
    this.iconContainerColor,
    this.borderColor,
    this.shadowColor,
    this.margin,
    this.padding,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;
  final Widget? badge;
  final Gradient? gradient;
  final Color? iconColor;
  final Color? iconContainerColor;
  final Color? borderColor;
  final Color? shadowColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveGradient = gradient ?? colors.executiveHeroGradient;
    final effectiveBorder =
        borderColor ?? colors.executiveGoldAccent.withValues(alpha: .32);
    final effectiveShadow =
        shadowColor ?? colors.emeraldDark.withValues(alpha: .23);
    final effectiveIconColor = iconColor ?? colors.executiveGoldIcon;
    final effectiveIconContainerColor =
        iconContainerColor ?? Colors.white.withValues(alpha: .13);

    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: effectiveGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: effectiveBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: effectiveShadow,
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
          BoxShadow(
            color: colors.shadow.withValues(alpha: .08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // الدائرة الهندسية الزجاجية العلوية
          PositionedDirectional(
            end: -18.r,
            top: -28.r,
            child: Container(
              width: 112.r,
              height: 112.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .055),
              ),
            ),
          ),

          // الحلقة الهندسية الزجاجية السفلية
          PositionedDirectional(
            end: 40.r,
            bottom: -48.r,
            child: Container(
              width: 90.r,
              height: 90.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .08),
                  width: 16.r,
                ),
              ),
            ),
          ),

          // المحتوى الداخلي للترويسة
          Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: effectiveIconContainerColor,
                        borderRadius: BorderRadius.circular(17.r),
                        border: Border.all(
                          color: effectiveIconColor.withValues(alpha: .38),
                        ),
                      ),
                      child: Icon(icon, color: effectiveIconColor, size: 27.r),
                    ),
                    AppSpacing.hMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTypography.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (badge != null) ...[AppSpacing.hXs, badge!],
                            ],
                          ),
                          AppSpacing.vXs,
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: .88),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (action != null) ...[
                  AppSpacing.vMd,
                  Row(children: [const Spacer(), action!]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
