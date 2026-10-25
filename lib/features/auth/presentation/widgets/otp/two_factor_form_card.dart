import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// بطاقة إدخال رمز التحقق بخطوتين وتأكيد الجهاز (TwoFactorFormCard)
/// مصممة وفق أسلوب التركيز الغامر العالمي بدون إطارات مقيدة
class TwoFactorFormCard extends GetView<TwoFactorAuthController> {
  const TwoFactorFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. حقل إدخال الرمز الموحد (CustomPinField) بنمط 3-3 ومؤشر التركيز
          Center(
            child: CustomPinField(
              length: 6,
              controller: controller.otpController,
              autofocus: true,
              useNativeKeyboard: true,
              validator: FormValidators.otpValidator(
                fieldName: 'رمز الأمان',
                length: 6,
              ),
              onCompleted: (pin) => controller.submitOtp(pin),
            ),
          ),

          AppSpacing.vLg,

          // 2. مؤشر التهدئة وإعادة الإرسال الهادئ
          Center(
            child: Obx(() {
              if (controller.canResend.value) {
                return CustomButton.text(
                  text: 'إعادة إرسال رمز الأمان',
                  icon: Icons.refresh_rounded,
                  loading: controller.isResending.value,
                  // foregroundColor: colors.primary,
                  // textStyle: AppTypography.labelLarge.copyWith(
                  //   fontWeight: FontWeight.w700,
                  // ),
                  onPressed: controller.resendOtp,
                );
              }
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 15.r,
                      color: colors.onSurfaceVariant,
                    ),
                    AppSpacing.hXxs,
                    Text(
                      'إعادة إرسال الرمز بعد ${controller.cooldownSeconds.value} ثانية',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          AppSpacing.vXxl,

          // 3. زر تأكيد الرمز والمصادقة المباشر
          Obx(
            () => CustomButton.primary(
              text: 'تأكيد الجهاز والدخول',
              icon: Icons.lock_open_rounded,
              size: AppButtonSize.large,
              height: 52.h,
              loading: controller.isLoading.value,
              onPressed: () => controller.submitOtp(),
            ),
          ),

          AppSpacing.vMd,

          // 4. زر الإلغاء والعودة الهادئ
          Center(
            child: CustomButton.text(
              text: 'إلغاء والعودة لتسجيل الدخول',
              icon: Icons.arrow_back_rounded,
              // foregroundColor: colors.onSurfaceVariant,
              onPressed: controller.cancelAndGoBack,
            ),
          ),
        ],
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
