import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_section_header.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// قسم البيانات التعريفية وهوية الباقة وشبكة التبعية
class PackageFormIdentitySection extends GetView<PackageCatalogController> {
  const PackageFormIdentitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PackageFormSectionHeader(
          icon: Icons.info_outline_rounded,
          title: 'البيانات التعريفية للباقة',
        ),
        AppSpacing.vSm,

        // اختيار الشبكة عند تعدد الشبكات المعتمدة
        Obx(() {
          if (controller.isEditing.value) {
            return const SizedBox.shrink();
          }

          if (controller.isLoadingNetworks.value) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: const LinearProgressIndicator(),
            );
          }

          if (controller.authorizedNetworks.length > 1) {
            final networks = controller.authorizedNetworks;
            final selectedId = controller.formNetworkId.value;

            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: CustomDropdown<int>(
                label: 'شبكة الكروت التابعة',
                searchEnabled: false,
                valueListenable: ValueNotifier<int?>(selectedId),
                items: networks.map((net) {
                  return DropdownItem<int>(
                    value: net.networkId,
                    child: Text(net.networkName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    controller.formNetworkId.value = val;
                  }
                },
              ),
            );
          }

          return const SizedBox.shrink();
        }),

        // اسم الباقة
        CustomTextField(
          controller: controller.nameController,
          label: 'اسم باقة الكروت',
          hint: 'مثال: باقة البرق 5 جيجا',
          prefixIcon: const Icon(Icons.label_outline_rounded),
          validator: FormValidators.customTextValidator(
            fieldName: 'اسم باقة الكروت',
            maxLength: 50,
            isRequired: true,
          ),
        ),

        AppSpacing.vMd,

        // لون الباقة
        Obx(() {
          return CustomColorPicker(
            label: 'لون الباقة المميز (Brand Color)',
            selectedColorHex: controller.selectedColorHex.value,
            onColorChanged: (newHex) {
              controller.selectedColorHex.value = newHex;
            },
          );
        }),
      ],
    );
  }
}

