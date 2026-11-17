import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/images/custom_cached_image.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// الأحجام القياسية لويدجيت الأفاتار والشعار الموحد
enum AvatarBadgeSize {
  sm(36, 12, 5),
  md(52, 16, 6),
  lg(72, 22, 8);

  final double dimension;
  final double fontSize;
  final double pulseSize;

  const AvatarBadgeSize(this.dimension, this.fontSize, this.pulseSize);
}

/// ويدجيت عام موحد للأفاتار والشعار مع هالة متدرجة ومؤشر نبض حي (CustomAvatarBadge)
/// قابل للاستخدام في أي شاشة أو مشروع بدون أي ارتباط بنطاق عمل مساحات العمل
class CustomAvatarBadge extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final AvatarBadgeSize size;
  final double? customDimension;
  final bool hasPulse;
  final Color? pulseColor;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CustomAvatarBadge({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = AvatarBadgeSize.md,
    this.customDimension,
    this.hasPulse = true,
    this.pulseColor,
    this.gradientColors,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dim = (customDimension ?? size.dimension).r;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(AppRadius.lg);
    final innerRadius = BorderRadius.circular(
      (effectiveRadius.topLeft.x - 1.5).clamp(2.0, 99.0),
    );

    final effectiveGradients =
        gradientColors ?? [colors.primary, colors.secondary];

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            gradient: LinearGradient(
              colors: effectiveGradients,
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveGradients.first.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: innerRadius,
              color: isDark ? const Color(0xFF0E1522) : colors.surface,
            ),
            alignment: Alignment.center,
            child: (imageUrl != null && imageUrl!.isNotEmpty)
                ? CustomCachedImage.avatar(
                    url: imageUrl,
                    radius: (dim / 2) - 2.5,
                    fallbackText: initials,
                  )
                : Text(
                    initials,
                    style: AppTypography.titleMedium.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: size.fontSize.sp,
                    ),
                  ),
          ),
        ),
        if (hasPulse)
          Positioned(
            bottom: -1,
            left: -1,
            child: CustomPulsingIndicator(
              color: pulseColor ?? colors.primary,
              size: size.pulseSize.r,
              enablePing: true,
            ),
          ),
      ],
    );

    if (onTap != null) {
      return CustomInteractiveBounce(onTap: onTap, child: content);
    }

    return content;
  }
}
