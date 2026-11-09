import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_section_header.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم التعرفة المالية والخصومات الافتراضية للباقة مع الالتزام بالسلطة الحصرية للخادم
class PackageFormPricingSection extends GetView<PackageCatalogController> {
  const PackageFormPricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PackageFormSectionHeader(
          icon: Icons.payments_outlined,
          title: 'التعرفة المالية والخصومات الافتراضية',
        ),
        AppSpacing.vSm,

        // السعر الأساسي للكرت
        CustomTextField(
          controller: controller.priceController,
          label: 'السعر الأساسي للكرت (Base Price)',
          hint: 'مثال: 1000',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.attach_money_rounded),
          validator: FormValidators.amountValidator(
            fieldName: 'السعر الأساسي للكرت',
            isRequired: true,
            minValue: 0,
          ),
        ),

        AppSpacing.vSm,

        // نسب الخصم الافتراضي (نقدي وآجل)
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.cashDiscountController,
                label: 'الخصم النقدي الافتراضي %',
                hint: 'مثال: 10.0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.price_change_outlined),
                isRequired: false,
                validator: FormValidators.percentageValidator(
                  fieldName: 'الخصم النقدي الافتراضي',
                  isRequired: false,
                  min: 0,
                  max: 100,
                ),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: CustomTextField(
                controller: controller.creditDiscountController,
                label: 'الخصم الآجل الافتراضي %',
                hint: 'مثال: 5.0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: const Icon(Icons.credit_card_outlined),
                isRequired: false,
                validator: FormValidators.percentageValidator(
                  fieldName: 'الخصم الآجل الافتراضي',
                  isRequired: false,
                  min: 0,
                  max: 100,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.vMd,

        // إشعار سلطة الخادم الحصرية للحسابات المالية (AGENTS.md §3)
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_outlined,
                size: AppSpacing.lg,
                color: colors.primary,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'يتم احتساب وتثبيت كافة الأسعار الصافية والخصومات التعاقدية حصرياً عبر الخادم المالي للنظام.',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
