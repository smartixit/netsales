import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/membership/presentation/controllers/membership_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

class MembershipAddForm extends StatelessWidget {
  const MembershipAddForm({super.key, required this.controller});
  final MembershipController controller;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: context.colors.outlineVariant.withValues(alpha: .45),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('إضافة عضو جديد', style: AppTypography.titleMedium),
        AppSpacing.vMd,
        CustomTextField(
          controller: controller.phoneController,
          label: 'رقم هاتف المستخدم المسجل',
          hint: 'أدخل الرقم المرتبط بحسابه في NetSales',
          keyboardType: TextInputType.phone,
        ),
        AppSpacing.vSm,
        Obx(
          () => CustomDropdown<int>(
            items: controller.roles
                .map(
                  (role) => DropdownItem<int>(
                    value: role.roleId,
                    child: Text(role.name),
                  ),
                )
                .toList(),
            rxValue: controller.selectedRoleId,
            onChanged: (value) => controller.selectedRoleId.value = value,
            label: 'الدور التشغيلي',
            hint: 'اختر الدور',
            enabled: controller.roles.isNotEmpty,
          ),
        ),
        AppSpacing.vMd,
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Obx(
            () => CustomButton.primary(
              text: 'إضافة إلى الفريق',
              icon: Icons.person_add_alt_1_rounded,
              loading: controller.isMutating.value,
              onPressed: controller.isMutating.value ? null : controller.add,
            ),
          ),
        ),
      ],
    ),
  );
}
