import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/profile/presentation/controllers/profile_edit_form_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شاشة تعديل الملف الشخصي — نقيّة عبر [GetView<ProfileEditFormController>].
class EditProfileScreen extends GetView<ProfileEditFormController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppScaffold(
      appBarTitle: 'تعديل الملف الشخصي',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomSurfaceCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.fullNameController,
                      label: 'الاسم الكامل',
                      hint: 'أدخل اسمك الكامل',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      textInputAction: TextInputAction.next,
                      validator: controller.fullNameValidator,
                    ),
                    AppSpacing.vMd,
                    CustomTextField(
                      controller: controller.phoneController,
                      label: 'رقم الهاتف',
                      hint: '7XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: controller.phoneValidator,
                    ),
                    AppSpacing.vMd,
                    CustomTextField(
                      controller: controller.emailController,
                      label: 'البريد الإلكتروني (اختياري)',
                      hint: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      isRequired: false,
                      validator: controller.emailValidator,
                      onFieldSubmitted: (_) => controller.submit(),
                    ),
                  ],
                ),
              ),
              AppSpacing.vXl,
              Obx(
                () => CustomButton(
                  text: 'حفظ التعديلات',
                  variant: AppButtonVariant.primary,
                  icon: Icons.check_rounded,
                  width: double.infinity,
                  loading: controller.isLoading.value,
                  onPressed: controller.submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
