import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item.dart';

/// بطاقة عرض محتوى شريحة التعريف الواحدة
class OnboardingPageCard extends StatelessWidget {
  const OnboardingPageCard({
    super.key,
    required this.item,
  });

  final OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. الحاوية البصرية للرسوم المتحركة أو الأيقونة
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 200.h,
                  maxWidth: 240.w,
                ),
                child: Center(
                  child: item.animationAsset != null
                      ? Lottie.asset(
                          item.animationAsset!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _buildFallbackIcon(colors),
                        )
                      : _buildFallbackIcon(colors),
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          AppSpacing.vLg,

          // 2. شارة التصنيف البصرية (Badge Pill)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              item.badge,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),

          AppSpacing.vMd,

          // 3. العنوان الرئيسي للشريحة
          Text(
            item.title,
            style: AppTypography.headlineSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),

          AppSpacing.vSm,

          // 4. النص الوصفي والتفصيلي
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              item.description,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildFallbackIcon(AppColors colors) {
    return Container(
      width: 140.r,
      height: 140.r,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        item.icon,
        size: 64.r,
        color: colors.primary,
      ),
    );
  }
}
