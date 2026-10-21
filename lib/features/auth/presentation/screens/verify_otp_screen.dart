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
import 'package:netsales/features/auth/presentation/controllers/verify_otp_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';

/// واجهة التحقق من رمز الاستعادة OTP المعتمدة على Pinput (VerifyOtpScreen)
class VerifyOtpScreen extends GetView<VerifyOtpController> {
  const VerifyOtpScreen({super.key});

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
          onPressed: controller.goToChangePhone,
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
                  // 1. قسم الترويسة والأيقونة الإرشادية
                  _buildHeader(context),

                  AppSpacing.vXl,

                  // 2. بطاقة نموذج إدخال الرمز
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

  /// قسم الترويسة مع رقم الهاتف المقنع
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
            Icons.sms_outlined,
            color: colors.primary,
            size: 40.r,
          ),
        ),
        AppSpacing.vMd,
        Text(
          'رمز التحقق (OTP)',
          style: AppTypography.headlineSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vXs,
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'تم إرسال رمز التحقق المكون من 6 أرقام إلى\nرقم الهاتف '),
              TextSpan(
                text: controller.maskedPhone,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

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
            // حقل إدخال الرمز الموحد (CustomPinField)
            CustomPinField(
              length: 6,
              controller: controller.otpController,
              autofocus: true,
              validator: FormValidators.otpValidator(
                fieldName: 'رمز التحقق',
                length: 6,
              ),
              onCompleted: (pin) => controller.submitOtp(pin),
            ),

            AppSpacing.vLg,

            // عداد التهدئة وزر إعادة الإرسال
            Obx(() {
              if (controller.canResend.value) {
                return CustomButton.text(
                  text: 'إعادة إرسال الرمز',
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

            // زر تأكيد الرمز
            Obx(
              () => CustomButton.primary(
                text: 'تأكيد واستلام كلمة المرور',
                icon: Icons.verified_user_outlined,
                iconSize: 20.r,
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
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.1, end: 0);
  }
}
