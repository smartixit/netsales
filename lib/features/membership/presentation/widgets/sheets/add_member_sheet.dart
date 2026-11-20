import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_phone_field.dart';

/// شيت إضافة عضو جديد لمساحة العمل (AddMemberSheet)
///
/// ودجت عرض نقي 100% يستهلك المكون القياسي [CustomPhoneField]
/// مع إسناد الصلاحيات من خلال [CustomDropdown].
class AddMemberSheet extends StatelessWidget {
  const AddMemberSheet({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.selectedRoleId,
    required this.roles,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
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
          // حقل رقم الهاتف المؤسسي الموحد من lib/widgets/inputs/
          CustomPhoneField(
            controller: phoneController,
            label: 'رقم هاتف المستخدم',
            hint: '77XXXXXXX',
            validator: FormValidators.phoneValidator(
              fieldName: 'رقم هاتف المستخدم',
            ),
          ),
          AppSpacing.vSm,

          // قائمة اختيار الدور الوظيفي المتاح للإسناد
          CustomDropdown<int>(
            label: 'الدور الوظيفي المعتمد',
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

          // زر تأكيد الإضافة
          Obx(
            () => CustomButton.primary(
              text: 'تأكيد إضافة العضو',
              icon: Icons.person_add_rounded,
              loading: isSubmitting.value,
              onPressed: isSubmitting.value ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}
