import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/two_factor_auth_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// بطاقة إدخال رمز التحقق بخطوتين وتأكيد الجهاز (TwoFactorFormCard)
class TwoFactorFormCard extends StatelessWidget {
  final TwoFactorAuthController controller;

  const TwoFactorFormCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
            CustomPinField(
              length: 6,
              controller: controller.otpController,
              autofocus: true,
              validator: FormValidators.otpValidator(
                fieldName: 'رمز الأمان',
                length: 6,
              ),
              onCompleted: (pin) => controller.submitOtp(pin),
            ),

            AppSpacing.vLg,

            // عداد التهدئة وزر إعادة الإرسال
            Obx(() {
              if (controller.canResend.value) {
                return CustomButton.text(
                  text: 'إعادة إرسال رمز الأمان',
                  icon: Icons.refresh_rounded,
                  loading: controller.isResending.value,
                  onPressed: controller.resendOtp,
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              );
            }),

            AppSpacing.vLg,

            // زر تأكيد الرمز والمصادقة
            Obx(
              () => CustomButton.primary(
                text: 'تأكيد الجهاز والدخول',
                icon: Icons.lock_open_rounded,
                iconSize: 20.r,
                loading: controller.isLoading.value,
                onPressed: () => controller.submitOtp(),
              ),
            ),

            AppSpacing.vSm,

            // زر الإلغاء والعودة
            CustomButton.text(
              text: 'إلغاء والعودة لتسجيل الدخول',
              icon: Icons.arrow_back_rounded,
              onPressed: controller.cancelAndGoBack,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0);
  }
}
