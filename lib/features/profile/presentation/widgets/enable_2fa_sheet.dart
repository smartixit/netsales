import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_2fa_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// محتوى نافذة تفعيل التحقق بخطوتين عبر OTP — نقي عبر [GetView].
class Enable2faSheet extends GetView<Profile2faController> {
  const Enable2faSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Form(
      key: controller.enableFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSurfaceCard(
            padding: EdgeInsets.all(AppSpacing.md),
            backgroundColor: colors.primary.withValues(alpha: 0.06),
            borderColor: colors.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(Icons.sms_outlined, color: colors.primary),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    'اطلب رمز التحقق أولاً ثم أدخل الرمز المكوّن من 6 أرقام لتفعيل الحماية.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          Obx(() {
            final canResend = controller.canResend.value;
            final seconds = controller.cooldownSeconds.value;
            final sent = controller.otpSent.value;
            return CustomButton(
              text: canResend
                  ? (sent ? 'إعادة إرسال رمز التحقق' : 'إرسال رمز التحقق')
                  : 'إعادة الإرسال خلال $seconds ثانية',
              variant: sent
                  ? AppButtonVariant.outline
                  : AppButtonVariant.primary,
              icon: Icons.send_rounded,
              width: double.infinity,
              loading: controller.isRequestingOtp.value,
              enabled: canResend,
              onPressed: controller.requestOtpForEnable,
            );
          }),
          Obx(() {
            if (!controller.otpSent.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.vLg,
                CustomTextField(
                  controller: controller.otpController,
                  label: 'رمز التحقق (OTP)',
                  hint: 'أدخل الرمز المكوّن من 6 أرقام',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  validator: controller.otpValidator,
                  onFieldSubmitted: (_) => controller.enableTwoFactor(),
                ),
                AppSpacing.vMd,
                CustomButton(
                  text: 'تأكيد وتفعيل التحقق بخطوتين',
                  variant: AppButtonVariant.primary,
                  width: double.infinity,
                  loading: controller.isEnabling.value,
                  onPressed: controller.enableTwoFactor,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
