import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_phone_field.dart';

/// بطاقة نموذج استعادة كلمة المرور الموحدة
class ForgotPasswordFormCard extends GetView<ForgotPasswordController> {
  const ForgotPasswordFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: AppElevation.level1(context),
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. حقل رقم الهاتف الموحد
                CustomPhoneField(
                  controller: controller.phoneController,
                  label: 'رقم الهاتف',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => controller.submit(),
                ),

                AppSpacing.vXl,

                // 2. زر المتابعة الرئيسي
                Obx(
                  () => CustomButton.primary(
                    text: 'إرسال رمز التحقق',
                    icon: Icons.send_rounded,
                    size: AppButtonSize.large,
                    height: 52.h,
                    loading: controller.isLoading.value,
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                  ),
                ),

                AppSpacing.vLg,

                // 3. رابط العودة لتسجيل الدخول بهدوء
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تذكرت كلمة المرور؟',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    CustomButton.text(
                      text: 'تسجيل الدخول',
                      onPressed: controller.goToLogin,
                      // foregroundColor: colors.primary,
                      // textStyle: AppTypography.titleSmall.copyWith(
                      //   fontWeight: FontWeight.w700,
                      // ),
                      // padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
