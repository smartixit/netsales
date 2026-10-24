import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';

/// رأس شاشة تسجيل الدخول: الشعار المركزي، العنوان، والوصف الترحيبي الهادئ
class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. الشعار المركزي الأنيق بحجمه المتوسط المتناسق
        const CustomBrandLogo.md()
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
          'تسجيل الدخول',
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

        // 3. النص الترحيبي الهادئ المريح
        Text(
          'أهلاً بك مجدداً، سجّل دخولك للمتابعة',
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
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
