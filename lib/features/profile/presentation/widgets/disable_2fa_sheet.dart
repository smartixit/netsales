import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_2fa_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// محتوى نافذة تعطيل التحقق بخطوتين — يتطلب كلمة المرور الحالية.
class Disable2faSheet extends GetView<Profile2faController> {
  const Disable2faSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;

    return Form(
      key: controller.disableFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSurfaceCard(
            padding: EdgeInsets.all(AppSpacing.md),
            backgroundColor: colors.error.withValues(alpha: 0.06),
            borderColor: colors.error.withValues(alpha: 0.25),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.error),
                AppSpacing.hSm,
                Expanded(
                  child: Text(
                    'تعطيل التحقق بخطوتين يقلل من مستوى أمان حسابك. يرجى تأكيد هويتك بكلمة المرور الحالية.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: controller.disablePasswordController,
            label: 'كلمة المرور الحالية',
            hint: 'أدخل كلمة المرور الحالية',
            obscureText: true,
            enablePasswordToggle: true,
            textInputAction: TextInputAction.done,
            validator: controller.passwordValidator,
            onFieldSubmitted: (_) => controller.disableTwoFactor(),
          ),
          AppSpacing.vLg,
          Obx(
            () => CustomButton(
              text: 'تأكيد تعطيل التحقق بخطوتين',
              variant: AppButtonVariant.danger,
              width: double.infinity,
              loading: controller.isDisabling.value,
              onPressed: controller.disableTwoFactor,
            ),
          ),
        ],
      ),
    );
  }
}
