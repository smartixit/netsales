import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_password_field.dart';

/// حوار تأكيد تعطيل المصادقة الثنائية (يتطلب إدخال كلمة المرور الحالية)
class TwoFactorDisableDialog extends StatelessWidget {
  const TwoFactorDisableDialog({super.key, required this.controller});

  final SecuritySettingsController controller;

  static Future<void> show(SecuritySettingsController controller) async {
    controller.disablePasswordController.clear();
    await CustomDialog.show(
      type: DialogType.warning,
      title: 'تعطيل المصادقة الثنائية',
      message:
          'تعطيل هذه الميزة يقلل من أمان حسابك ويسمح بالدخول بكلمة المرور فقط دون رمز التحقق الإضافي.',
      confirmLabel: 'تأكيد التعطيل',
      cancelLabel: 'إلغاء',
      onConfirm: controller.submitDisable2fa,
      content: TwoFactorDisableDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.vMd,
        Text(
          'لأسباب أمنية، يرجى إدخال كلمة المرور الحالية لتأكيد هويتك:',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        CustomPasswordField(
          controller: controller.disablePasswordController,
          label: 'كلمة المرور الحالية',
          hint: 'أدخل كلمة المرور الحالية',
          autofocus: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => controller.submitDisable2fa(),
        ),
      ],
    );
  }
}
