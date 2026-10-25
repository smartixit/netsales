import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/widgets/inputs/custom_password_field.dart';
import 'package:netsales/widgets/inputs/custom_phone_field.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_contact_picker_icon_button.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';

/// بطاقة إدخال بيانات وكيل ومسؤول نقطة البيع والصورة الشخصية (PosAgentInfoCard)
class PosAgentInfoCard extends GetView<RegisterPosController> {
  const PosAgentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: AppElevation.level1(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // رأس القسم مع مؤشر الخطوة
              Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.person_pin_rounded,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بيانات وكيل ومسؤول نقطة البيع',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          'معلومات الهوية وبيانات تسجيل الدخول',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'الخطوة 2 من 2',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              AppSpacing.vLg,

              // منتقي الصورة الشخصية للوكيل
              CustomImagePicker.avatar(
                label: 'الصورة الشخصية للوكيل',
                hint: 'اختياري',
                valueListenable: controller.agentAvatar,
              ),

              AppSpacing.vMd,

              // اسم الوكيل الكامل
              CustomTextField(
                controller: controller.agentNameController,
                label: 'الاسم الكامل للوكيل / المسؤول',
                hint: 'الاسم الثلاثي أو الرباعي',
                prefixIcon: Icon(Icons.badge_outlined, size: 20.r),
                validator: FormValidators.nameValidator(
                  fieldName: 'اسم الوكيل',
                  minWordsCount: 2,
                  maxWordsCount: 6,
                ),
              ),

              AppSpacing.vMd,

              // رقم الجوال الموحد مع منتقي جهات الاتصال المعتمد
              CustomPhoneField(
                controller: controller.phoneController,
                label: 'رقم الهاتف',
                suffixIcon: CustomContactPickerIconButton(
                  controller: controller.phoneController,
                  nameController: controller.agentNameController,
                ),
                validator: FormValidators.phoneValidator(
                  fieldName: 'رقم هاتف الوكيل',
                ),
              ),

              AppSpacing.vMd,

              // كلمة المرور الموحدة
              CustomPasswordField(
                controller: controller.passwordController,
                label: 'كلمة المرور',
                hint: '8 أحرف على الأقل',
                textInputAction: TextInputAction.next,
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
        )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
        );
  }
}
