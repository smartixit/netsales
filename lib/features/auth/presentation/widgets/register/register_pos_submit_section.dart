import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// قسم زر إرسال طلب تسجيل نقطة البيع وروابط التوجيه (RegisterPosSubmitSection)
class RegisterPosSubmitSection extends GetView<RegisterPosController> {
  const RegisterPosSubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. زر إرسال الطلب الأساسي
        Obx(() {
          return CustomButton.primary(
            text: 'إرسال طلب التسجيل',
            icon: Icons.app_registration_rounded,
            iconSize: 20.r,
            size: AppButtonSize.large,
            height: 52.h,
            loading: controller.isLoading.value,
            onPressed: controller.submitRegistration,
          );
        }),

        AppSpacing.vMd,

        // 2. إشعار الموافقة على الشروط والخصوصية
        Text(
          'بالضغط على "إرسال طلب التسجيل"، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بمنصة NetSales.',
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant.withValues(alpha: 0.75),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        AppSpacing.vLg,

        // 3. رابط العودة لتسجيل الدخول
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.xs,
          children: [
            Text(
              'لديك حساب نقطة بيع مسبقاً؟',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            CustomButton.text(
              text: 'تسجيل الدخول',
              foregroundColor: colors.primary,
              textStyle: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              onPressed: controller.goToLogin,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
        );
  }
}
