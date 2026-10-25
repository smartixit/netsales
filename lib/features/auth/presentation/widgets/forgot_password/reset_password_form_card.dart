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
import 'package:netsales/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_password_field.dart';
import 'package:netsales/widgets/inputs/custom_password_requirement_item.dart';

/// بطاقة نموذج تعيين وتأكيد كلمة المرور الجديدة الهندسية الموحدة
class ResetPasswordFormCard extends GetView<ResetPasswordController> {
  const ResetPasswordFormCard({super.key});

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
            // 1. كلمة المرور الحالية أو المؤقتة (تُعرض فقط عند التغيير المسجل/الإلزامي وليس عند الاستعادة بالرمز)
            if (!controller.isDirectReset) ...[
              CustomPasswordField(
                controller: controller.currentPasswordController,
                label: controller.isForced
                    ? 'كلمة المرور المؤقتة (الحالية)'
                    : 'كلمة المرور الحالية',
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.lock_clock_rounded,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20.r,
                ),
                validator: FormValidators.required(
                  fieldName: controller.isForced
                      ? 'كلمة المرور المؤقتة'
                      : 'كلمة المرور الحالية',
                ),
              ),
              AppSpacing.vLg,
            ],

            // 2. كلمة المرور الجديدة
            CustomPasswordField.newPassword(
              controller: controller.newPasswordController,
              validator: FormValidators.passwordValidator(
                fieldName: 'كلمة المرور الجديدة',
                minLength: 8,
              ),
            ),

            AppSpacing.vSm,

            // 3. شريط مقياس قوة كلمة المرور مع المعايير الذكية
            Obx(() {
              final score = controller.passwordScore.value;
              final Color meterColor = score <= 0.4
                  ? colors.error
                  : (score <= 0.7 ? colors.warning : colors.success);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                    child: LinearProgressIndicator(
                      value: score,
                      minHeight: 4.h,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(meterColor),
                    ),
                  ),
                  AppSpacing.vSm,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      CustomPasswordRequirementItem(
                        label: '8 أحرف على الأقل',
                        isValid: controller.hasMinLength.value,
                      ),
                      CustomPasswordRequirementItem(
                        label: 'حرف كبير (A-Z)',
                        isValid: controller.hasUppercase.value,
                      ),
                      CustomPasswordRequirementItem(
                        label: 'حرف صغير (a-z)',
                        isValid: controller.hasLowercase.value,
                      ),
                      CustomPasswordRequirementItem(
                        label: 'رقم (0-9)',
                        isValid: controller.hasDigit.value,
                      ),
                      CustomPasswordRequirementItem(
                        label: 'رمز خاص (!@#\$%)',
                        isValid: controller.hasSpecialChar.value,
                      ),
                    ],
                  ),
                ],
              );
            }),

            AppSpacing.vLg,

            // 4. تأكيد كلمة المرور الجديدة
            CustomPasswordField.confirm(
              controller: controller.confirmPasswordController,
              prefixIcon: Icon(
                Icons.lock_reset_rounded,
                color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                size: 20.r,
              ),
              validator: FormValidators.confirmPasswordValidator(
                fieldName: 'تأكيد كلمة المرور',
                passwordController: controller.newPasswordController,
              ),
              onFieldSubmitted: (_) => controller.submit(),
            ),

            AppSpacing.vXl,

            // 5. زر الحفظ وتأكيد الهوية
            Obx(
              () => CustomButton.primary(
                text: controller.isDirectReset
                    ? 'حفظ كلمة المرور والدخول'
                    : 'حفظ وتأمين الحساب',
                icon: Icons.check_circle_outline_rounded,
                size: AppButtonSize.large,
                height: 52.h,
                loading: controller.isLoading.value,
                onPressed: controller.submit,
              ),
            ),

            AppSpacing.vSm,

            // 6. زر الإلغاء
            CustomButton.text(
              text: controller.isDirectReset
                  ? 'رجوع'
                  : (controller.isForced
                      ? 'تسجيل الخروج والعودة لاحقاً'
                      : 'إلغاء'),
              onPressed: controller.abortOrLogout,
              foregroundColor: colors.onSurfaceVariant,
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
