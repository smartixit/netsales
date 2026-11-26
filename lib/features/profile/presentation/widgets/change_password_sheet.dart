import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// محتوى نافذة تغيير كلمة المرور — نقي عبر [GetView].
class ChangePasswordSheet extends GetView<ChangePasswordController> {
  const ChangePasswordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: controller.currentPasswordController,
            label: 'كلمة المرور الحالية',
            hint: 'أدخل كلمة المرور الحالية',
            obscureText: true,
            enablePasswordToggle: true,
            textInputAction: TextInputAction.next,
            validator: controller.currentPasswordValidator,
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: controller.newPasswordController,
            label: 'كلمة المرور الجديدة',
            hint: '6 أحرف على الأقل',
            obscureText: true,
            enablePasswordToggle: true,
            textInputAction: TextInputAction.next,
            validator: controller.newPasswordValidator,
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: controller.confirmPasswordController,
            label: 'تأكيد كلمة المرور الجديدة',
            hint: 'أعد كتابة كلمة المرور الجديدة',
            obscureText: true,
            enablePasswordToggle: true,
            textInputAction: TextInputAction.done,
            validator: controller.confirmPasswordValidator,
            onFieldSubmitted: (_) => controller.submit(),
          ),
          AppSpacing.vLg,
          Obx(
            () => CustomButton(
              text: 'حفظ كلمة المرور الجديدة',
              variant: AppButtonVariant.primary,
              width: double.infinity,
              loading: controller.isLoading.value,
              onPressed: controller.submit,
            ),
          ),
        ],
      ),
    );
  }
}
