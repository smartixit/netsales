import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ترويسة شاشة تسجيل نقطة بيع / وكيل جديد (RegisterPosHeaderSection)
class RegisterPosHeaderSection extends StatelessWidget {
  const RegisterPosHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. أيقونة نقطة البيع الهندسية المعتمدة
        Container(
          width: 56.r,
          height: 56.r,
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: colors.primary,
            size: 28.r,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: AppMotion.normal,
              curve: AppMotion.springy,
            )
            .fadeIn(duration: AppMotion.normal),

        AppSpacing.vMd,

        // 2. العنوان الرئيسي
        Text(
          'تسجيل نقطة بيع جديدة',
          style: AppTypography.headlineMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
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

        AppSpacing.vXs,

        // 3. النص الإرشادي
        Text(
          'انضم كوكيل ونقطة بيع معتمدة وأصدر كروت الإنترنت بكل سهولة وموثوقية',
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
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
      ],
    );
  }
}
