import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:netsales/features/auth/presentation/widgets/password_requirement_item.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// واجهة تعيين وتغيير كلمة المرور الإلزامية والاختيارية (ResetPasswordScreen)
class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: !controller.isForced,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.abortOrLogout();
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              controller.isForced ? Icons.logout_rounded : Icons.arrow_back_ios_new_rounded,
              color: colors.onSurface,
              size: 20.r,
            ),
            tooltip: controller.isForced ? 'تسجيل الخروج' : 'رجوع',
            onPressed: controller.abortOrLogout,
          ),
          title: Text(
            controller.isForced ? 'تأمين الحساب' : 'تغيير كلمة المرور',
            style: AppTypography.titleMedium.copyWith(color: colors.onSurface),
          ),
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppGradients.surfaceMesh(context),
          ),
          child: SafeArea(
            child: ResponsiveContentWrapper(
              maxWidth: AppBreakpoints.maxFormWidth,
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: AppSpacing.lg,
                    tablet: AppSpacing.xl,
                  ),
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. شارة التنبيه الأمني المؤسسي
                    _buildSecurityBanner(context),

                    AppSpacing.vLg,

                    // 2. بطاقة النموذج
                    _buildFormCard(context),

                    AppSpacing.vLg,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بطاقة التنبيه الأمني في أعلى الشاشة
  Widget _buildSecurityBanner(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: controller.isForced
            ? colors.warning.withValues(alpha: 0.12)
            : colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: controller.isForced
              ? colors.warning.withValues(alpha: 0.3)
              : colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.isForced
                  ? colors.warning.withValues(alpha: 0.2)
                  : colors.primary.withValues(alpha: 0.15),
            ),
            child: Icon(
              controller.isForced
                  ? Icons.shield_outlined
                  : Icons.lock_reset_rounded,
              color: controller.isForced ? colors.warning : colors.primary,
              size: 24.r,
            ),
          ),
          AppSpacing.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isForced
                      ? 'مطلوب تعيين كلمة مرور جديدة'
                      : 'تحديث كلمة المرور لحسابك',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.vXxs,
                Text(
                  controller.isForced
                      ? 'تم تسجيل الدخول باستخدام كلمة مرور مؤقتة عبر الرسائل القصيرة. لحماية بياناتك وعملياتك، يُلزم النظام تعيين كلمة مرور جديدة قبل المتابعة.'
                      : 'احرص على اختيار كلمة مرور قوية وغير مستخدمة في تطبيقات أخرى.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  /// بطاقة إدخال الحقول
  Widget _buildFormCard(BuildContext context) {
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
            // 1. كلمة المرور الحالية أو المؤقتة
            Obx(
              () => CustomTextField(
                controller: controller.currentPasswordController,
                label: controller.isForced
                    ? 'كلمة المرور المؤقتة (الحالية)'
                    : 'كلمة المرور الحالية',
                hint: '••••••••',
                obscureText: !controller.isCurrentPasswordVisible.value,
                enablePasswordToggle: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.lock_clock_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isCurrentPasswordVisible.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  onPressed: controller.toggleCurrentPasswordVisibility,
                ),
                validator: FormValidators.required(
                  fieldName: controller.isForced
                      ? 'كلمة المرور المؤقتة'
                      : 'كلمة المرور الحالية',
                ),
              ),
            ),

            AppSpacing.vLg,

            // 2. كلمة المرور الجديدة
            Obx(
              () => CustomTextField(
                controller: controller.newPasswordController,
                label: 'كلمة المرور الجديدة',
                hint: '••••••••',
                obscureText: !controller.isNewPasswordVisible.value,
                enablePasswordToggle: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isNewPasswordVisible.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  onPressed: controller.toggleNewPasswordVisibility,
                ),
                validator: FormValidators.passwordValidator(
                  fieldName: 'كلمة المرور الجديدة',
                  minLength: 8,
                ),
              ),
            ),

            AppSpacing.vSm,

            // 3. شريط مقياس قوة كلمة المرور
            Obx(() {
              final score = controller.passwordScore.value;
              final Color meterColor = score <= 0.4
                  ? colors.error
                  : (score <= 0.7 ? colors.warning : colors.success);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: score,
                      minHeight: 5.h,
                      backgroundColor: colors.outlineVariant.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(meterColor),
                    ),
                  ),
                  AppSpacing.vXs,
                  // معايير كلمة المرور
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        PasswordRequirementItem(
                          isValid: controller.hasMinLength.value,
                          label: '8 خانات على الأقل',
                        ),
                        PasswordRequirementItem(
                          isValid: controller.hasUppercase.value &&
                              controller.hasLowercase.value,
                          label: 'أحرف كبيرة وصغيرة (A-z)',
                        ),
                        PasswordRequirementItem(
                          isValid: controller.hasDigit.value,
                          label: 'أرقام (0-9)',
                        ),
                        PasswordRequirementItem(
                          isValid: controller.hasSpecialChar.value,
                          label: 'رموز خاصة (!@#\$%^&*)',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            AppSpacing.vLg,

            // 4. تأكيد كلمة المرور الجديدة
            Obx(
              () => CustomTextField(
                controller: controller.confirmPasswordController,
                label: 'تأكيد كلمة المرور الجديدة',
                hint: '••••••••',
                obscureText: !controller.isConfirmPasswordVisible.value,
                enablePasswordToggle: true,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icon(
                  Icons.lock_reset_rounded,
                  color: colors.primary,
                  size: 22.r,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isConfirmPasswordVisible.value
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: colors.onSurfaceVariant,
                    size: 20.r,
                  ),
                  onPressed: controller.toggleConfirmPasswordVisibility,
                ),
                validator: FormValidators.confirmPasswordValidator(
                  fieldName: 'تأكيد كلمة المرور',
                  passwordController: controller.newPasswordController,
                ),
                onFieldSubmitted: (_) => controller.submit(),
              ),
            ),

            AppSpacing.vXl,

            // 5. زر الحفظ وتأكيد الهوية
            Obx(
              () => CustomButton.primary(
                text: 'حفظ وتأمين الحساب',
                icon: Icons.check_circle_outline_rounded,
                iconSize: 20.r,
                loading: controller.isLoading.value,
                onPressed: controller.submit,
              ),
            ),

            AppSpacing.vSm,

            // 6. زر الإلغاء
            CustomButton.text(
              text: controller.isForced ? 'تسجيل الخروج والعودة لاحقاً' : 'إلغاء',
              onPressed: controller.abortOrLogout,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0);
  }
}
