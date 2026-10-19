import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/brand/custom_brand_logo.dart';

/// رأس شاشة تسجيل الدخول: الشعار المركزي، العنوان، والوصف الترحيبي
class LoginHeaderSection extends StatelessWidget {
  const LoginHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. الشعار المركزي مع هالة ضوئية متناسقة
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
            const CustomBrandLogo.lg(),
          ],
        )
            .animate()
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              duration: AppMotion.normal,
              curve: AppMotion.springy,
            )
            .fadeIn(duration: AppMotion.normal),

        AppSpacing.vLg,

        // 2. شارة التصنيف المؤسسية
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppSpacing.xl),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            'بوابة الدخول الموحدة',
            style: AppTypography.labelMedium.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        AppSpacing.vSm,

        // 3. العنوان الرئيسي
        Text(
          'تسجيل الدخول إلى حسابك',
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

        // 4. النص الإرشادي والترحيب
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'أدخل رقم الهاتف وكلمة المرور للوصول إلى لوحة إدارة مبيعات الشبكات ونقاط البيع.',
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
    );
  }
}
