import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/auth/presentation/controllers/security_settings_controller.dart';
import 'package:netsales/widgets/dialogs/custom_dialog.dart';
import 'package:netsales/widgets/inputs/custom_password_field.dart';

/// حوار تأكيد تعطيل المصادقة الثنائية (يتطلب إدخال كلمة المرور الحالية)
class TwoFactorDisableDialog extends StatefulWidget {
  const TwoFactorDisableDialog({super.key, required this.controller});

  final SecuritySettingsController controller;

  static Future<void> show(
    BuildContext context,
    SecuritySettingsController controller,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TwoFactorDisableDialog(controller: controller),
    );
  }

  @override
  State<TwoFactorDisableDialog> createState() => _TwoFactorDisableDialogState();
}

class _TwoFactorDisableDialogState extends State<TwoFactorDisableDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) return;

    final success = await widget.controller.confirmDisable2fa(password);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomDialog(
      type: DialogType.warning,
      title: 'تعطيل المصادقة الثنائية',
      message: 'تعطيل هذه الميزة يقلل من أمان حسابك ويسمح بالدخول بكلمة المرور فقط دون رمز التحقق الإضافي.',
      confirmLabel: 'تأكيد التعطيل',
      cancelLabel: 'إلغاء',
      onCancel: () => Navigator.of(context).pop(),
      onConfirm: _submit,
      content: Form(
        key: _formKey,
        child: Column(
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
              controller: _passwordController,
              label: 'كلمة المرور الحالية',
              hint: 'أدخل كلمة المرور الحالية',
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
    );
  }
}
