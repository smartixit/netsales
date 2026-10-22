import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة نموذج تسجيل الدخول (الحقول وأزرار الإجراءات)
class LoginFormCard extends GetView<LoginController> {
  const LoginFormCard({super.key});

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
            // 1. حقل رقم الهاتف
            CustomTextField(
              controller: controller.phoneController,
              label: 'رقم الهاتف',
              hint: '77XXXXXXX',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                Icons.phone_iphone_rounded,
                color: colors.primary,
              ),
              validator: FormValidators.phoneValidator(
                fieldName: 'رقم الهاتف',
              ),
            ),

            AppSpacing.vLg,

            // 2. حقل كلمة المرور
            CustomTextField(
              controller: controller.passwordController,
              label: 'كلمة المرور',
              hint: '••••••••',
              obscureText: true,
              enablePasswordToggle: true,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: colors.primary,
              ),
              validator: FormValidators.passwordValidator(
                fieldName: 'كلمة المرور',
              ),
              onFieldSubmitted: (_) => controller.submitLogin(),
            ),

            AppSpacing.vSm,

            // 3. رابط نسيت كلمة المرور
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton.text(
                text: 'نسيت كلمة المرور؟',
                onPressed: controller.goToForgotPassword,
                foregroundColor: colors.primary,
                textStyle: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxs,
                ),
              ),
            ),

            AppSpacing.vXl,

            // 4. زر تسجيل الدخول الرئيسي
            Obx(
              () => CustomButton.primary(
                text: 'تسجيل الدخول',
                icon: Icons.login_rounded,
                loading: controller.isLoading.value,
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitLogin,
              ),
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
