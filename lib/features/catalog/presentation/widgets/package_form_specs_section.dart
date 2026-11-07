import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_section_header.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم المواصفات الفنية للكرت (رصيد، وقت استخدام، صلاحية، عدد الكروت)
class PackageFormSpecsSection extends GetView<PackageCatalogController> {
  const PackageFormSpecsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PackageFormSectionHeader(
          icon: Icons.tune_rounded,
          title: 'المواصفات الفنية للكرت',
        ),
        AppSpacing.vSm,

        // حجم الرصيد + اختيار وحدة القياس (MB / GB)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.balanceController,
                label: 'حجم الرصيد',
                hint: 'مثال: 5120',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.data_usage_rounded),
                isRequired: false,
                validator: FormValidators.doubleValidator(
                  fieldName: 'حجم الرصيد',
                  isRequired: false,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 2,
              child: CustomDropdown<DataUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                valueListenable: controller.selectedBalanceUnit,
                items: DataUnit.values.map((unit) {
                  return DropdownItem<DataUnit>(
                    value: unit,
                    child: Text(unit.label),
                  );
                }).toList(),
                onChanged: (newUnit) {
                  if (newUnit != null) {
                    controller.setBalanceUnit(newUnit);
                  }
                },
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // وقت الاستخدام + اختيار وحدة الوقت (دقيقة / ساعة)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.uptimeController,
                label: 'وقت الاستخدام',
                hint: 'مثال: 60',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.timer_outlined),
                isRequired: false,
                validator: FormValidators.doubleValidator(
                  fieldName: 'وقت الاستخدام',
                  isRequired: false,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 2,
              child: CustomDropdown<UptimeUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                valueListenable: controller.selectedUptimeUnit,
                items: UptimeUnit.values.map((unit) {
                  return DropdownItem<UptimeUnit>(
                    value: unit,
                    child: Text(unit.label),
                  );
                }).toList(),
                onChanged: (newUnit) {
                  if (newUnit != null) {
                    controller.setUptimeUnit(newUnit);
                  }
                },
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // مدة الصلاحية + اختيار وحدة الصلاحية (ساعة / يوم)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.validityController,
                label: 'مدة الصلاحية',
                hint: 'مثال: 30',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                isRequired: false,
                validator: FormValidators.doubleValidator(
                  fieldName: 'مدة الصلاحية',
                  isRequired: false,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              flex: 2,
              child: CustomDropdown<ValidityUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                valueListenable: controller.selectedValidityUnit,
                items: ValidityUnit.values.map((unit) {
                  return DropdownItem<ValidityUnit>(
                    value: unit,
                    child: Text(unit.label),
                  );
                }).toList(),
                onChanged: (newUnit) {
                  if (newUnit != null) {
                    controller.setValidityUnit(newUnit);
                  }
                },
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // عدد الكروت في الحزمة
        CustomTextField(
          controller: controller.voucherCountController,
          label: 'عدد الكروت في الحزمة',
          hint: 'الافتراضي: 1',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.confirmation_number_outlined),
          isRequired: false,
          validator: FormValidators.integerValidator(
            fieldName: 'عدد الكروت',
            isRequired: false,
          ),
        ),
      ],
    );
  }
}

