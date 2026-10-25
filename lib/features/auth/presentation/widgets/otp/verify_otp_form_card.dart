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
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// بطاقة نموذج إدخال رمز التحقق OTP الهندسية الموحدة
/// مصممة وفق أسلوب التطبيقات العالمية: مساحة تركيز غامرة خالية من الإطارات الثقيلة
class VerifyOtpFormCard extends GetView<VerifyOtpController> {
  const VerifyOtpFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. حقل إدخال الرمز الموحد (CustomPinField) بنمط 3-3 مع التعبئة التلقائية للرسائل
          Center(
            child: CustomPinField(
              length: 6,
              controller: controller.otpController,
              autofocus: true,
              useNativeKeyboard: true,
              validator: FormValidators.otpValidator(
                fieldName: 'رمز التحقق',
                length: 6,
              ),
              onCompleted: (pin) => controller.goToDirectReset(pin),
            ),
          ),

          AppSpacing.vLg,

          // 2. سطر التهدئة وإعادة الإرسال الهادئ (Resend Timer)
          Center(
            child: Obx(() {
              if (controller.canResend.value) {
                return CustomButton.text(
                  text: 'إعادة إرسال رمز التحقق',
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

          // 3. الإجراء الأساسي المباشر
          Obx(
            () => CustomButton.primary(
              text: 'متابعة وتعيين كلمة المرور',
              icon: Icons.arrow_forward_rounded,
              size: AppButtonSize.large,
              height: 52.h,
              loading: controller.isLoading.value,
              onPressed: () => controller.goToDirectReset(),
            ),
          ),

          AppSpacing.vMd,

          // 4. المسار البديل (رابط نصي خفيف غير منافس)
          Obx(
            () => Center(
              child: CustomButton.text(
                text: 'استلام كلمة مرور مؤقتة عبر SMS',
                icon: Icons.sms_outlined,
                // foregroundColor: colors.onSurfaceVariant,
                loading: controller.isLoading.value,
                onPressed: () => controller.submitOtp(),
              ),
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
