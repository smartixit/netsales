import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// شيت تعديل دور وصلاحيات العضو (ChangeMemberRoleSheet)
///
/// ودجت عرض نقي 100% يستهلك المكون القياسي [CustomDropdown].
class ChangeMemberRoleSheet extends StatelessWidget {
  const ChangeMemberRoleSheet({
    super.key,
    required this.formKey,
    required this.selectedRoleId,
    required this.roles,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final RxnInt selectedRoleId;
  final List<MembershipRoleEntity> roles;
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
            label: 'الدور الوظيفي الجديد',
            searchEnabled: false,
            rxValue: selectedRoleId,
            items: roles
                .map(
                  (role) => DropdownItem<int>(
                    value: role.roleId,
                    child: Text(role.displayName),
                  ),
                )
                .toList(),
            onChanged: (val) => selectedRoleId.value = val,
          ),
          AppSpacing.vMd,
          Obx(
            () => CustomButton.primary(
              text: 'حفظ الدور الجديد',
              icon: Icons.check_circle_outline_rounded,
              loading: isSubmitting.value,
              onPressed: isSubmitting.value ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
