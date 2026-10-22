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
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_numeric_keyboard.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// بطاقة نموذج إدخال رمز التحقق OTP (VerifyOtpFormCard)
class VerifyOtpFormCard extends StatelessWidget {
  final VerifyOtpController controller;

  const VerifyOtpFormCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final animDuration = AppMotion.duration(context, AppMotion.normal);

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // حقل إدخال الرمز الموحد (CustomPinField)
            Obx(
              () => CustomPinField(
                length: 6,
                controller: controller.otpController,
                autofocus: true,
                useNativeKeyboard: !controller.isCustomKeyboard.value,
                validator: FormValidators.otpValidator(
                  fieldName: 'رمز التحقق',
                  length: 6,
                ),
                onCompleted: (pin) => controller.goToDirectReset(pin),
              ),
            ),

            AppSpacing.vMd,

            // شريط مؤشر التهدئة وزر تبديل لوحة المفاتيح
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // عداد التهدئة أو زر إعادة الإرسال
                  if (controller.canResend.value)
                    CustomButton.text(
                      text: 'إعادة إرسال الرمز',
                      icon: Icons.refresh_rounded,
                      loading: controller.isResending.value,
                      onPressed: controller.resendOtp,
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16.r,
                          color: colors.onSurfaceVariant,
                        ),
                        AppSpacing.hXs,
                        Text(
                          'إعادة الإرسال بعد ${controller.cooldownSeconds.value} ثانية',
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                  // زر تبديل نمط لوحة المفاتيح بين المدمجة وكيبورد النظام
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

            // لوحة المفاتيح الرقمية المدمجة (تظهر عند تفعيل الوضع المدمج)
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
                    onCompleted: (pin) => controller.goToDirectReset(pin),
                  ),
                ],
              );
            }),

            AppSpacing.vLg,

            // الإجراء الأساسي: تعيين كلمة مرور جديدة مباشرة
            Obx(
              () => CustomButton.primary(
                text: 'تعيين كلمة مرور جديدة',
                icon: Icons.lock_reset_rounded,
                iconSize: 20.r,
                loading: controller.isLoading.value,
                onPressed: () => controller.goToDirectReset(),
              ),
            ),

            AppSpacing.vSm,

            // المسار البديل: استلام كلمة مرور مؤقتة عبر SMS
            Obx(
              () => CustomButton.outline(
                text: 'استلام كلمة مرور مؤقتة عبر SMS',
                icon: Icons.sms_outlined,
                iconSize: 18.r,
                loading: controller.isLoading.value,
                onPressed: () => controller.submitOtp(),
              ),
            ),

            AppSpacing.vSm,

            // زر تعديل رقم الهاتف
            CustomButton.text(
              text: 'تعديل رقم الهاتف',
              icon: Icons.edit_outlined,
              onPressed: controller.goToChangePhone,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: animDuration).slideY(
          begin: 0.1,
          end: 0,
          curve: AppMotion.standard,
        );
  }
}
