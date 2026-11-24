import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_form_profit_radar.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم التسعير والخصومات الافتراضية وحالة التفعيل (Pricing Form Section)
///
/// يعتمد 100% على توكنز النظام المركزية ويفوض الرادار الحسابي لـ [PackageFormProfitRadar]
class PackagePricingFormSection extends GetView<PackageFormController> {
  const PackagePricingFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSectionHeading(
          icon: Icons.payments_outlined,
          title: 'التسعير والخصومات الافتراضية',
          subtitle: 'تحديد سعر الكرت الأساسي (فئة الكرت) ونسب الخصم الافتراضي للشراء النقدي والآجل.',
        ),
        AppSpacing.vSm,

        // سعر الكرت الأساسي
        CustomTextField(
          controller: controller.priceController,
          label: 'سعر الكرت الأساسي (فئة الكرت)',
          hint: 'مثال: 500',
          prefixIcon: const Icon(Icons.attach_money_rounded),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isRequired: true,
          validator: FormValidators.doubleValidator(
            fieldName: 'سعر الكرت الأساسي',
          ),
        ),

        AppSpacing.vSm,

        // نسب الخصم الافتراضية
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.cashDiscountController,
                label: 'الخصم النقدي (%)',
                hint: '0.0',
                prefixIcon: const Icon(Icons.discount_outlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isRequired: true,
                validator: FormValidators.percentageValidator(
                  fieldName: 'الخصم النقدي',
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                controller: controller.creditDiscountController,
                label: 'الخصم الآجل (%)',
                hint: '0.0',
                prefixIcon: const Icon(Icons.credit_score_outlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                isRequired: true,
                validator: FormValidators.percentageValidator(
                  fieldName: 'الخصم الآجل',
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // رادار الأرباح وهوامش الجملة التفاعلي الحي
        const PackageFormProfitRadar(),

        AppSpacing.vMd,

        // مفتاح تفعيل الباقة
        Obx(
          () => CustomSwitchListTile(
            title: 'حالة تفعيل الباقة',
            subtitle: controller.status.value
                ? 'الباقة نشطة ومتاحة لطلبات الشراء'
                : 'الباقة معطلة وغير متاحة لطلبات الشراء',
            value: controller.status.value,
            onChanged: (val) => controller.status.value = val,
          ),
        ),
      ],
    );
  }
}
