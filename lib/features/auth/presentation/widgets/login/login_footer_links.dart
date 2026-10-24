import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// تذييل شاشة تسجيل الدخول: رابط إنشاء حساب وتأكيد أمان الجلسة بهدوء ووقار
class LoginFooterLinks extends GetView<LoginController> {
  const LoginFooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. رابط إنشاء حساب جديد بهدوء وبدون فواصل مشتتة
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ليس لديك حساب في النظام؟',
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomButton.text(
              text: 'إنشاء حساب جديد',
              onPressed: controller.goToRegister,
              // foregroundColor: colors.primary,
              // textStyle: AppTypography.titleSmall.copyWith(
              //   fontWeight: FontWeight.w700,
              // ),
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
          ],
        ),

        AppSpacing.vLg,

        // 2. شارة الأمان السيادي الهادئة
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Icon(
        //       Icons.lock_outline_rounded,
        //       size: 14.r,
        //       color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        //     ),
        //     AppSpacing.hXs,
        //     Text(
        //       'جلسة مؤمنة بنظام التشفير السيادي والرقابة',
        //       style: AppTypography.bodySmall.copyWith(
        //         color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    ).animate().fadeIn(duration: AppMotion.normal);
  }
}
