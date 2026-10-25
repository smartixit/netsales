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
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_numeric_keyboard.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// بطاقة إدخال رمز التحقق بخطوتين وتأكيد الجهاز (TwoFactorFormCard)
class TwoFactorFormCard extends GetView<TwoFactorAuthController> {
  const TwoFactorFormCard({super.key});

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
            // 1. حقل إدخال الرمز الموحد (CustomPinField)
            Obx(
              () => CustomPinField(
                length: 6,
                controller: controller.otpController,
                autofocus: true,
                useNativeKeyboard: !controller.isCustomKeyboard.value,
                validator: FormValidators.otpValidator(
                  fieldName: 'رمز الأمان',
                  length: 6,
                ),
                onCompleted: (pin) => controller.submitOtp(pin),
              ),
            ),

            AppSpacing.vLg,

            // 2. شريط مؤشر التهدئة وزر تبديل لوحة المفاتيح
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // عداد التهدئة أو زر إعادة الإرسال
                  if (controller.canResend.value)
                    CustomButton.text(
                      text: 'إعادة إرسال رمز الأمان',
                      icon: Icons.refresh_rounded,
                      loading: controller.isResending.value,
                      onPressed: controller.resendOtp,
                      foregroundColor: colors.primary,
                      textStyle: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
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
                            size: 14.r,
                            color: colors.onSurfaceVariant,
                          ),
                          AppSpacing.hXxs,
                          Text(
                            'إعادة الإرسال بعد ${controller.cooldownSeconds.value} ث',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // زر تبديل نمط لوحة المفاتيح
                  CustomButton.icon(
                    icon: controller.isCustomKeyboard.value
                        ? Icons.keyboard_outlined
                        : Icons.dialpad_rounded,
                    tooltip: controller.isCustomKeyboard.value
                        ? 'استخدام لوحة مفاتيح النظام'
                        : 'استخدام اللوحة الرقمية المدمجة',
                    iconSize: 18.r,
                    dimension: 36.r,
                    foregroundColor: colors.onSurfaceVariant,
                    backgroundColor:
                        colors.surfaceContainerHighest.withValues(alpha: 0.35),
                    onPressed: controller.toggleKeyboard,
                  ),
                ],
              );
            }),

            // 3. لوحة المفاتيح الرقمية المدمجة
            Obx(() {
              if (!controller.isCustomKeyboard.value) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSpacing.vMd,
                  CustomNumericKeyboard(
                    controller: controller.otpController,
                    maxLength: 6,
                    onToggleKeyboard: controller.toggleKeyboard,
                    onCompleted: (pin) => controller.submitOtp(pin),
                  ),
                ],
              );
            }),

            AppSpacing.vXl,

            // 4. زر تأكيد الرمز والمصادقة
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

            AppSpacing.vSm,

            // 5. زر الإلغاء والعودة
            CustomButton.text(
              text: 'إلغاء والعودة لتسجيل الدخول',
              icon: Icons.arrow_back_rounded,
              onPressed: controller.cancelAndGoBack,
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
