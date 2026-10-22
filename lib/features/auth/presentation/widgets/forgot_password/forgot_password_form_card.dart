import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة نموذج إدخال رقم الهاتف لاستعادة كلمة المرور (ForgotPasswordFormCard)
class ForgotPasswordFormCard extends StatelessWidget {
  final ForgotPasswordController controller;

  const ForgotPasswordFormCard({
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
            // حقل رقم الهاتف المعتمد على FormValidators
            CustomTextField(
              controller: controller.phoneController,
              label: 'رقم الهاتف المسجل',
              hint: '77XXXXXXX',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              prefixIcon: Icon(
                Icons.phone_iphone_rounded,
                color: colors.primary,
                size: 22.r,
              ),
              validator: FormValidators.phoneValidator(
                fieldName: 'رقم الهاتف',
              ),
              onFieldSubmitted: (_) => controller.submit(),
            ),

            AppSpacing.vXl,

            // زر المتابعة
            Obx(
              () => CustomButton.primary(
                text: 'إرسال رمز التحقق',
                icon: Icons.send_rounded,
                iconSize: 20.r,
                loading: controller.isLoading.value,
                onPressed: controller.submit,
              ),
            ),

            AppSpacing.vSm,

            // زر العودة لتسجيل الدخول
            CustomButton.text(
              text: 'تذكرت كلمة المرور؟ تسجيل الدخول',
              onPressed: controller.goToLogin,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0);
  }
}
