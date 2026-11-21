import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/features/membership/domain/entities/workspace_member_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// واجهة سفلية تصريحية بحتة لتعديل الدور الوظيفي للعضو (Change Member Role Presentation Sheet)
class ChangeMemberRoleSheet extends StatelessWidget {
  const ChangeMemberRoleSheet({
    super.key,
    required this.member,
    required this.assignableRoles,
    required this.formKey,
    required this.reasonController,
    required this.roleNotifier,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final WorkspaceMemberEntity member;
  final List<MembershipRoleEntity> assignableRoles;
  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final ValueNotifier<int?> roleNotifier;
  final RxBool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomDropdown<int>(
            label: 'الدور الجديد',
            hint: 'اختر الدور الجديد للعضو',
            valueListenable: roleNotifier,
            items: assignableRoles
                .map(
                  (role) => DropdownItem<int>(
                    value: role.roleId,
                    child: Text(role.roleName),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) roleNotifier.value = val;
            },
          ),
          AppSpacing.vMd,
          CustomTextField(
            controller: reasonController,
            label: 'سبب التعديل (اختياري)',
            hint: 'أدخل سبب ترقية أو تعديل دور العضو...',
            maxLines: 2,
            isRequired: false,
            validator: FormValidators.descriptionValidator(isRequired: false),
          ),
          AppSpacing.vLg,
          Obx(
            () => CustomButton.primary(
              text: 'حفظ وتحديث الدور',
              icon: Icons.check_rounded,
              loading: isSubmitting.value,
              onPressed: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
