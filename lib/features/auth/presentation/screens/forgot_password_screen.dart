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
import 'package:netsales/features/auth/presentation/controllers/forgot_password_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// واجهة طلب استعادة كلمة المرور (ForgotPasswordScreen)
class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onSurface,
            size: 20.r,
          ),
          tooltip: 'رجوع',
          onPressed: controller.goToLogin,
        ),
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
                  // 1. قسم الشعار والترحيب الإرشادي
                  _buildHeader(context),

                  AppSpacing.vXl,

                  // 2. بطاقة النموذج
                  _buildFormCard(context),

                  AppSpacing.vLg,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// قسم الترويسة والأيقونة التوضيحية
  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        Container(
          width: 80.r,
          height: 80.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
              width: 2.w,
            ),
          ),
          child: Icon(
            Icons.lock_reset_rounded,
            color: colors.primary,
            size: 40.r,
          ),
        ),
        AppSpacing.vMd,
        Text(
          'نسيت كلمة المرور؟',
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXs,
        Text(
          'أدخل رقم هاتفك المسجل في النظام، وسنرسل لك رمز تحقق مؤقت (OTP) لتأكيد هويتك واستعادة الحساب.',
          style: AppTypography.bodyMedium.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  /// بطاقة نموذج إدخال رقم الهاتف
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
