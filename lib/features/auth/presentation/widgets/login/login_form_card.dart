import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/login_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_phone_field.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// بطاقة نموذج تسجيل الدخول المهندسة وفق أرقى المعايير العالمية وتجربة الاستخدام المريحة
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
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: AppElevation.level1(context),
          ),
          child: AutofillGroup(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. حقل رقم الهاتف الموحد
                  CustomPhoneField(
                    controller: controller.phoneController,
                    textInputAction: TextInputAction.next,
                  ),

                  AppSpacing.vLg,

                  // 2. حقل كلمة المرور مع دعم التعبئة التلقائية والإرسال المباشر
                  CustomTextField(
                    controller: controller.passwordController,
                    label: 'كلمة المرور',
                    hint: '••••••••',
                    obscureText: true,
                    enablePasswordToggle: true,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 20.r,
                    ),
                    validator: FormValidators.required(
                      fieldName: 'كلمة المرور',
                    ),
                    onFieldSubmitted: (_) => controller.submitLogin(),
                  ),

                  // AppSpacing.vSm,

                  // 3. رابط استعادة كلمة المرور بمحاذاة طبيعية لجهة القراءة
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CustomButton.text(
                      text: 'نسيت كلمة المرور؟',
                      onPressed: controller.goToForgotPassword,
                    ),
                  ),

                  AppSpacing.vSm,

                  // 4. الإجراء الرئيسي مع دعم البصمة السريعة
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => CustomButton.primary(
                            text: 'تسجيل الدخول',
                            icon: Icons.login_rounded,
                            size: AppButtonSize.large,
                            height: 52.h,
                            loading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.submitLogin,
                          ),
                        ),
                      ),
                      Obx(() {
                        if (!controller.canCheckBiometrics.value) {
                          return const SizedBox.shrink();
                        }
                        return Row(
                          children: [
                            AppSpacing.hSm,
                            CustomButton.icon(
                              dimension: 52.h,
                              icon: Icons.fingerprint_rounded,
                              iconSize: 26.r,
                              backgroundColor: colors.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              foregroundColor: colors.primary,
                              tooltip: 'تسجيل الدخول بالمقاييس الحيوية',
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.authenticateWithBiometrics,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
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
