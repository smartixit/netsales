import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/membership/domain/entities/membership_role_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// واجهة سفلية تصريحية بحتة لإدخال بيانات العضو الجديد (Add Member Presentation Sheet)
class AddMemberSheet extends StatelessWidget {
  const AddMemberSheet({
    super.key,
    required this.assignableRoles,
    required this.formKey,
    required this.phoneController,
    required this.roleNotifier,
    required this.statusNotifier,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final List<MembershipRoleEntity> assignableRoles;
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final ValueNotifier<int?> roleNotifier;
  final ValueNotifier<String?> statusNotifier;
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
          CustomTextField(
            controller: phoneController,
            label: 'رقم هاتف المستخدم',
            hint: 'أدخل رقم هاتف العضو المسجل بالمنظومة...',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            isRequired: true,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9+]*$')),
            ],
            validator: FormValidators.phoneValidator(fieldName: 'رقم الهاتف'),
          ),
          AppSpacing.vMd,
          CustomDropdown<int>(
            label: 'الدور الوظيفي',
            hint: 'اختر الدور والصلاحيات الممنوحة للعضو',
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
          CustomDropdown<String>(
            label: 'حالة التفعيل الأولية',
            hint: 'اختر حالة الحساب عند الإضافة',
            valueListenable: statusNotifier,
            items: const [
              DropdownItem(value: 'ACTIVE', child: Text('نشط ومفعل فورياً')),
              DropdownItem(
                value: 'INVITED',
                child: Text('بانتظار التأكيد (مدعو)'),
              ),
              DropdownItem(value: 'SUSPENDED', child: Text('موقوف مؤقتاً')),
            ],
            onChanged: (val) {
              if (val != null) statusNotifier.value = val;
            },
          ),
          AppSpacing.vLg,
          Obx(
            () => CustomButton.primary(
              text: 'إضافة العضو',
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
