import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// ترويسة شاشة استعادة كلمة المرور الهندسية الرشيقة
class ForgotPasswordHeaderSection extends StatelessWidget {
  const ForgotPasswordHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. أيقونة الاستعادة الهندسية الرشيقة
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
            Icons.lock_reset_rounded,
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
          'استعادة كلمة المرور',
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

        // 3. النص الإرشادي الهادئ المريح
        Text(
          'أدخل رقم هاتفك المسجل لنرسل لك رمز التحقق السريع',
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
