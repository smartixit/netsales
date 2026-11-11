import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_pin_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// نافذة سفلية لتأكيد تفعيل المصادقة الثنائية عبر إدخال رمز OTP
class TwoFactorEnableSheet extends StatelessWidget {
  const TwoFactorEnableSheet({super.key, required this.controller});

  final SecuritySettingsController controller;

  static Future<void> show(SecuritySettingsController controller) async {
    final success = await controller.requestOtpForEnable();
    if (!success) return;

    controller.otpController.clear();
    await CustomBottomSheet.show<void>(
      title: 'تأكيد تفعيل المصادقة الثنائية',
      subtitle: 'أدخل رمز التحقق (OTP) المكون من 6 أرقام المرسل إلى هاتفك',
      leadingIcon: Icons.security_rounded,
      scrollable: true,
      child: TwoFactorEnableSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sms_outlined,
                color: colors.primary,
                size: 20.sp,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'تم إرسال الرمز إلى رقم هاتفك المسجل: ${controller.maskedPhone}',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vLg,
        Center(
          child: CustomPinField(
            length: 6,
            controller: controller.otpController,
            autofocus: true,
            useNativeKeyboard: true,
            onCompleted: (_) => controller.submitEnableOtp(),
          ),
        ),
        AppSpacing.vMd,
        Center(
          child: Obx(() {
            if (controller.canResend.value) {
              return CustomButton.text(
                text: 'إعادة إرسال رمز التحقق',
                icon: Icons.refresh_rounded,
                loading: controller.isRequestingOtp.value,
                onPressed: controller.resendEnableOtp,
              );
            }
            return Text(
              'يمكنك إعادة طلب الرمز بعد ${controller.cooldownSeconds.value} ثانية',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            );
          }),
        ),
        AppSpacing.vLg,
        Obx(
          () => CustomButton.primary(
            text: 'تأكيد وتفعيل الحماية',
            icon: Icons.check_circle_outline_rounded,
            loading: controller.isActionLoading.value,
            onPressed: controller.submitEnableOtp,
          ),
        ),
        AppSpacing.vSm,
      ],
    );
  }
}
