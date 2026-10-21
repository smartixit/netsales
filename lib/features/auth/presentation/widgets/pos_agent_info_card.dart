import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_contact_picker_icon_button.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';

/// بطاقة إدخال بيانات وكيل ومسؤول نقطة البيع والصورة الشخصية (PosAgentInfoCard)
class PosAgentInfoCard extends StatelessWidget {
  final RegisterPosController controller;

  const PosAgentInfoCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin_rounded,
                color: colors.primary,
                size: 20.r,
              ),
              AppSpacing.hSm,
              Text(
                'بيانات وكيل ومسؤول نقطة البيع',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.vMd,

          // منتقي الصورة الشخصية للوكيل (CustomImagePicker.avatar)
          CustomImagePicker.avatar(
            label: 'الصورة الشخصية للوكيل',
            hint: 'اختياري',
            valueListenable: controller.agentAvatar,
          ),

          AppSpacing.vMd,

          // اسم الوكيل الكامل
          CustomTextField(
            controller: controller.agentNameController,
            label: 'الاسم الكامل للوكيل / المسؤول *',
            hint: 'الاسم الثلاثي أو الرباعي',
            prefixIcon: Icon(Icons.badge_outlined, size: 20.r),
            validator: FormValidators.nameValidator(
              fieldName: 'اسم الوكيل',
              minWordsCount: 2,
              maxWordsCount: 6,
            ),
          ),

          AppSpacing.vMd,

          // رقم الجوال مع منتقي جهات الاتصال المعتمد (CustomContactPickerIconButton)
          CustomTextField(
            controller: controller.phoneController,
            label: 'رقم الهاتف *',
            hint: '77XXXXXXX',
            prefixIcon: Icon(Icons.phone_iphone_rounded, size: 20.r),
            keyboardType: TextInputType.phone,
            suffixIcon: CustomContactPickerIconButton(
              controller: controller.phoneController,
              nameController: controller.agentNameController,
            ),
            validator: FormValidators.phoneValidator(
              fieldName: 'رقم هاتف الوكيل',
            ),
          ),

          AppSpacing.vMd,

          // كلمة المرور
          CustomTextField(
            controller: controller.passwordController,
            label: 'كلمة المرور *',
            hint: '8 أحرف على الأقل',
            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20.r),
            obscureText: true,
            enablePasswordToggle: true,
            validator: FormValidators.passwordValidator(
              fieldName: 'كلمة المرور',
            ),
          ),

          AppSpacing.vMd,

          // البريد الإلكتروني للوكيل (اختياري)
          CustomTextField(
            controller: controller.agentEmailController,
            label: 'البريد الإلكتروني للوكيل',
            hint: 'agent@example.com',
            prefixIcon: Icon(Icons.email_outlined, size: 20.r),
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.emailValidator(
              fieldName: 'البريد الإلكتروني للوكيل',
              isRequired: false,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
