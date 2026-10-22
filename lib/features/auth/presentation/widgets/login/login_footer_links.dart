import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/dividers/custom_labeled_divider.dart';

/// تذييل شاشة تسجيل الدخول: رابط إنشاء حساب جديد وتأكيد الأمان
class LoginFooterLinks extends GetView<LoginController> {
  const LoginFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. فاصل أنيق
        const CustomLabeledDivider(label: 'أو إذا لم يكن لديك حساب'),

        AppSpacing.vMd,

        // 2. زر إنشاء حساب جديد
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لا تملك حساباً في النظام؟',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomButton.text(
              text: 'إنشاء حساب جديد',
              onPressed: controller.goToRegister,
              foregroundColor: colors.primary,
              textStyle: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
          ],
        ),

        AppSpacing.vLg,

        // 3. شارة الأمان السيادي
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 16.r,
              color: colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            AppSpacing.hXs,
            Text(
              'محمي بتشفير سيادي وإدارة جلسات مشفرة',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: AppMotion.normal);
  }
}
