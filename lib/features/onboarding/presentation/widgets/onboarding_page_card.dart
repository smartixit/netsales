import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/onboarding/domain/entities/onboarding_item_entity.dart';

/// بطاقة عرض محتوى شريحة التعريف الواحدة
class OnboardingPageCard extends StatelessWidget {
  const OnboardingPageCard({super.key, required this.item});

  final OnboardingItemEntity item;

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
              // 1. الحاوية البصرية للرسوم المتحركة أو الصور التوضيحية
              ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 210.h,
                      maxWidth: 240.w,
                    ),
                    child: Center(child: _OnboardingVisual(item: item)),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: AppMotion.slow,
                    curve: AppMotion.springy,
                  )
                  .fadeIn(duration: AppMotion.normal),

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
                  .fadeIn(duration: AppMotion.normal)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: AppMotion.normal,
                    curve: AppMotion.emphasized,
                  ),

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
                  .fadeIn(duration: AppMotion.normal)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: AppMotion.normal,
                    curve: AppMotion.emphasized,
                  ),

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
                  .fadeIn(duration: AppMotion.normal)
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: AppMotion.normal,
                    curve: AppMotion.emphasized,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ودجت بصري متخصص لعرض الرسوم المتحركة أو الصورة لشريحة التعريف
class _OnboardingVisual extends StatelessWidget {
  final OnboardingItemEntity item;

  const _OnboardingVisual({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (item.animationAsset != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 180.r,
            height: 180.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primaryContainer.withValues(alpha: 0.25),
            ),
          ),
          Lottie.asset(
            item.animationAsset!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _OnboardingFallbackIcon(icon: item.icon),
          ),
        ],
      );
    }
    if (item.imageAsset != null) {
      return Image.asset(
        item.imageAsset!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _OnboardingFallbackIcon(icon: item.icon),
      );
    }
    return _OnboardingFallbackIcon(icon: item.icon);
  }
}

/// ودجت أيقونة بديلة لشريحة التعريف عند تعذر تحميل الرسوم
class _OnboardingFallbackIcon extends StatelessWidget {
  final IconData icon;

  const _OnboardingFallbackIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
      child: Icon(icon, size: 64.r, color: colors.primary),
    );
  }
}
