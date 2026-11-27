import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// قسم البيانات التعريفية وهوية الباقة في النموذج (General Info Section)
class PackageGeneralInfoSection extends GetView<PackageFormController> {
  const PackageGeneralInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSectionHeading(
          icon: Icons.info_outline_rounded,
          title: 'البيانات التعريفية وهوية الباقة',
          subtitle:
              'تحديد اسم الباقة، وشبكة التوزيع التابعة، ولون التمييز البصري.',
        ),
        AppSpacing.vSm,

        // مؤشر تحميل الشبكات في حالة الإنشاء
        Obx(() {
          if (!controller.isEditing.value &&
              controller.isLoadingNetworks.value) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CustomStateView.loading(
                presentation: CustomStatePresentation.skeletonOnly,
                skeleton: CustomStateSkeleton(
                  layout: CustomStateSkeletonLayout.text,
                  lineCount: 2,
                  showCardSurface: false,
                ),
              ),
            );
          }

          if (!controller.isEditing.value &&
              controller.networkLoadError.value != null) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعذر تحميل الشبكات: ${controller.networkLoadError.value}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  CustomButton.outline(
                    text: 'إعادة المحاولة',
                    icon: Icons.refresh_rounded,
                    shape: AppButtonShape.rounded,
                    size: AppButtonSize.small,
                    onPressed: controller.retryLoadNetworks,
                  ),
                ],
              ),
            );
          }

          if (!controller.isEditing.value &&
              controller.authorizedNetworks.length == 1) {
            final network = controller.authorizedNetworks.single;
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.hub_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شبكة الباقة',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            network.networkName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.verified_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!controller.isEditing.value &&
              controller.authorizedNetworks.length > 1) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: CustomDropdown<int>(
                label: 'الشبكة التابعة للباقة',
                searchEnabled: false,
                rxValue: controller.selectedNetworkId,
                items: controller.authorizedNetworks.map((net) {
                  return DropdownItem<int>(
                    value: net.networkId,
                    child: Text(net.networkName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedNetworkId.value = val;
                  }
                },
              ),
            );
          }

          if (!controller.isEditing.value &&
              !controller.isLoadingNetworks.value) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'لا توجد شبكة متاحة لإنشاء الباقة. تحقق من صلاحياتك أو أعد تحميل الصفحة.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        CustomTextField(
          controller: controller.nameController,
          label: 'اسم الباقة',
          hint: 'مثال: باقة النجم الأسبوعية 5GB',
          prefixIcon: const Icon(Icons.label_outline_rounded),
          isRequired: true,
          textInputAction: TextInputAction.next,
          validator: FormValidators.required(fieldName: 'اسم الباقة'),
        ),

        AppSpacing.vSm,

        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Obx(
            () => CustomColorPicker(
              label: 'لون تمييز كرت الباقة',
              selectedColorHex: controller.selectedColor.value,
              onColorChanged: (String hex) {
                controller.selectedColor.value = hex;
              },
            ),
          ),
        ),
      ],
    );
  }
}
