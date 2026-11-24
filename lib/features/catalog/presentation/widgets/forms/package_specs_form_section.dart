import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم المواصفات الفنية للباقة والحزمة (Specs Form Section)
class PackageSpecsFormSection extends GetView<PackageFormController> {
  const PackageSpecsFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSectionHeading(
          icon: Icons.tune_rounded,
          title: 'المواصفات الفنية وحجم الحزمة',
          subtitle: 'تحديد رصيد البيانات ووقت الاتصال المتاح وفترة الصلاحية وعدد الكروت.',
        ),
        AppSpacing.vSm,

        // عدد الكروت في الورقة
        CustomTextField(
          controller: controller.voucherCountController,
          label: 'عدد الكروت في الورقة',
          hint: 'مثال: 51',
          prefixIcon: const Icon(Icons.style_outlined),
          keyboardType: TextInputType.number,
          isRequired: true,
          validator: FormValidators.positiveIntegerValidator(
            fieldName: 'عدد الكروت في الورقة',
          ),
        ),

        AppSpacing.vSm,

        // رصيد البيانات مع محدد الوحدة
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.balanceController,
                label: 'رصيد البيانات',
                hint: '0',
                prefixIcon: const Icon(Icons.data_usage_rounded),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isRequired: true,
                validator: FormValidators.amountValidator(
                  fieldName: 'رصيد البيانات',
                  decimalPlaces: 12,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: CustomDropdown<DataSizeUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                rxValue: controller.selectedBalanceUnit,
                items:
                    [
                      DataSizeUnit.megabytes,
                      DataSizeUnit.gigabytes,
                      DataSizeUnit.terabytes,
                      DataSizeUnit.kilobytes,
                      DataSizeUnit.bytes,
                    ].map((unit) {
                      return DropdownItem<DataSizeUnit>(
                        value: unit,
                        child: Text('${unit.label} (${unit.symbol})'),
                      );
                    }).toList(),
                onValueChanging: (val) {
                  if (val != null) {
                    controller.setBalanceUnit(val);
                  }
                },
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // وقت الاتصال المسموح مع محدد الوحدة
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.uptimeController,
                label: 'وقت الاستخدام (اختياري)',
                hint: 'مفتوح',
                prefixIcon: const Icon(Icons.timer_outlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormValidators.amountValidator(
                  fieldName: 'وقت الاستخدام',
                  isRequired: false,
                  decimalPlaces: 12,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: CustomDropdown<TimeDurationUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                rxValue: controller.selectedUptimeUnit,
                items:
                    [
                      TimeDurationUnit.minutes,
                      TimeDurationUnit.hours,
                      TimeDurationUnit.days,
                      TimeDurationUnit.weeks,
                      TimeDurationUnit.months,
                    ].map((unit) {
                      return DropdownItem<TimeDurationUnit>(
                        value: unit,
                        child: Text('${unit.label} (${unit.symbol})'),
                      );
                    }).toList(),
                onValueChanging: (val) {
                  if (val != null) {
                    controller.setUptimeUnit(val);
                  }
                },
              ),
            ),
          ],
        ),

        AppSpacing.vSm,

        // فترة الصلاحية مع محدد الوحدة
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CustomTextField(
                controller: controller.validityController,
                label: 'فترة الصلاحية (اختياري)',
                hint: 'مفتوح',
                prefixIcon: const Icon(Icons.event_available_outlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: FormValidators.amountValidator(
                  fieldName: 'فترة الصلاحية',
                  isRequired: false,
                  decimalPlaces: 12,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: CustomDropdown<TimeDurationUnit>(
                label: 'الوحدة',
                searchEnabled: false,
                rxValue: controller.selectedValidityUnit,
                items:
                    [
                      TimeDurationUnit.minutes,
                      TimeDurationUnit.hours,
                      TimeDurationUnit.days,
                      TimeDurationUnit.weeks,
                      TimeDurationUnit.months,
                      TimeDurationUnit.years,
                    ].map((unit) {
                      return DropdownItem<TimeDurationUnit>(
                        value: unit,
                        child: Text('${unit.label} (${unit.symbol})'),
                      );
                    }).toList(),
                onValueChanging: (val) {
                  if (val != null) {
                    controller.setValidityUnit(val);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
