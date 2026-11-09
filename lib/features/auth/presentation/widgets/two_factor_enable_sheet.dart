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
class TwoFactorEnableSheet extends StatefulWidget {
  const TwoFactorEnableSheet({super.key, required this.controller});

  final SecuritySettingsController controller;

  static Future<void> show(
    BuildContext context,
    SecuritySettingsController controller,
  ) async {
    // 1. طلب رمز OTP قبل فتح النافذة
    final success = await controller.requestOtpForEnable();
    if (!success) return;

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TwoFactorEnableSheet(controller: controller),
    );
  }

  @override
  State<TwoFactorEnableSheet> createState() => _TwoFactorEnableSheetState();
}

class _TwoFactorEnableSheetState extends State<TwoFactorEnableSheet> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    final success = await widget.controller.confirmEnable2fa(otp);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CustomBottomSheet(
        title: 'تأكيد تفعيل المصادقة الثنائية',
        subtitle: 'أدخل رمز التحقق (OTP) المكون من 6 أرقام المرسل إلى هاتفك',
        leadingIcon: Icons.security_rounded,
        child: Form(
          key: _formKey,
          child: Column(
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
                        'تم إرسال الرمز إلى رقم هاتفك المسجل: ${widget.controller.maskedPhone}',
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
                  controller: _otpController,
                  autofocus: true,
                  useNativeKeyboard: true,
                  onCompleted: (pin) => _submit(),
                ),
              ),
              AppSpacing.vMd,
              Center(
                child: Obx(() {
                  if (widget.controller.canResend.value) {
                    return CustomButton.text(
                      text: 'إعادة إرسال رمز التحقق',
                      icon: Icons.refresh_rounded,
                      loading: widget.controller.isRequestingOtp.value,
                      onPressed: widget.controller.resendEnableOtp,
                    );
                  }
                  return Text(
                    'يمكنك إعادة طلب الرمز بعد ${widget.controller.cooldownSeconds.value} ثانية',
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
                  loading: widget.controller.isActionLoading.value,
                  onPressed: _submit,
                ),
              ),
              AppSpacing.vSm,
            ],
          ),
        ),
      ),
    );
  }
}
