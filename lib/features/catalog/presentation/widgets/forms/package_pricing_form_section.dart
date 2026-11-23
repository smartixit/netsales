import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_form_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/forms/package_estimate_row.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// قسم التسعير والخصومات الافتراضية وحالة التفعيل (Pricing Form Section)
///
/// يعتمد 100% على توكنز النظام المركزية (AppColors, AppSpacing, AppRadius, AppElevation)
class PackagePricingFormSection extends GetView<PackageFormController> {
  const PackagePricingFormSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomSectionHeading(
          icon: Icons.payments_outlined,
          title: 'التسعير والخصومات الافتراضية',
          subtitle:
              'تحديد سعر الحزمة الأساسي ونسب الخصم الافتراضي للشراء النقدي والآجل.',
        ),
        AppSpacing.vSm,

        // سعر الحزمة
        CustomTextField(
          controller: controller.priceController,
          label: 'سعر الحزمة الأساسي',
          hint: 'مثال: 5000',
          prefixIcon: const Icon(Icons.attach_money_rounded),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isRequired: true,
          validator: FormValidators.doubleValidator(
            fieldName: 'سعر الحزمة الأساسي',
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

        // بطاقة المعاينة الحية للأسعار المحسوبة (Interactive Display Estimate Card)
        Obx(() {
          final base = controller.liveBasePrice.value;
          final cashP = controller.estimatedCashPrice;
          final creditP = controller.estimatedCreditPrice;
          final cashD = controller.estimatedCashDiscountAmount;
          final creditD = controller.estimatedCreditDiscountAmount;

          return Container(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.15),
              ),
              boxShadow: AppElevation.level1(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calculate_outlined,
                      size: 20,
                      color: colors.primary,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'معاينة الحساب المالي التقديري للكرت',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: AppSpacing.xl,
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
                PackageEstimateRow(
                  label: 'السعر الأساسي للحزمة:',
                  value: AmountFormatter.formatValue(base),
                  color: colors.onSurface,
                ),
                SizedBox(height: AppSpacing.xs),
                PackageEstimateRow(
                  label:
                      'سعر الشراء الفعلي نقداً (خصم ${controller.liveCashDiscount.value.toStringAsFixed(0)}%):',
                  value: AmountFormatter.formatValue(cashP),
                  badgeText: 'وفر ${AmountFormatter.formatValue(cashD)}',
                  color: colors.success,
                ),
                SizedBox(height: AppSpacing.xs),
                PackageEstimateRow(
                  label:
                      'سعر الشراء الفعلي آجلاً (خصم ${controller.liveCreditDiscount.value.toStringAsFixed(0)}%):',
                  value: AmountFormatter.formatValue(creditP),
                  badgeText: 'وفر ${AmountFormatter.formatValue(creditD)}',
                  color: colors.info,
                ),
              ],
            ),
          );
        }),

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
