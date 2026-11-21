import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:netsales/widgets/forms/custom_section_heading.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// شاشة إنشاء وتعديل باقة كروت الإنترنت الموحدة (PackageFormScreen)
///
/// تجسد المعمارية المؤسسية النظيفة:
/// - واجهة متماسكة تصريحية بحتة خالية تماماً من دوال المساعدات (Zero Method Helpers).
/// - كلاس واحد في ملف واحد بمسؤولية واحدة (One Public Class Per File).
/// - استهلاك مباشر للمكونات العامة الموحدة [CustomSectionHeading] و [CustomSwitchListTile].
class PackageFormScreen extends GetView<PackageCatalogController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBarTitle: isEditing ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت جديدة',
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ──────────────────────────────────────────────────────────
                // 1. البيانات التعريفية وهوية الباقة
                // ──────────────────────────────────────────────────────────
                const CustomSectionHeading(
                  icon: Icons.info_outline_rounded,
                  title: 'البيانات التعريفية للباقة',
                  subtitle: 'تحديد اسم الباقة، وشبكة التوزيع التابعة، ولون التمييز البصري.',
                ),
                AppSpacing.vSm,

                if (!isEditing && controller.isLoadingNetworks.value)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: CustomStateView.loading(
                      presentation: CustomStatePresentation.skeletonOnly,
                      skeleton: CustomStateSkeleton(
                        layout: CustomStateSkeletonLayout.text,
                        lineCount: 2,
                        showCardSurface: false,
                      ),
                    ),
                  ),

                if (!isEditing && controller.authorizedNetworks.length > 1)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: CustomDropdown<int>(
                      label: 'شبكة الكروت التابعة',
                      searchEnabled: false,
                      rxValue: controller.formNetworkId,
                      items: controller.authorizedNetworks.map((net) {
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
                  ),

                CustomTextField(
                  controller: controller.nameController,
                  label: 'اسم الباقة',
                  hint: 'مثال: باقة النجم الأسبوعية 5GB',
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                  isRequired: true,
                  validator: FormValidators.required(fieldName: 'اسم الباقة'),
                ),

                AppSpacing.vSm,

                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لون تمييز الباقة',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXs,
                      CustomColorPicker(
                        selectedColorHex: controller.selectedColorHex.value,
                        onColorChanged: (String hex) =>
                            controller.selectedColorHex.value = hex,
                      ),
                    ],
                  ),
                ),

                AppSpacing.vLg,

                // ──────────────────────────────────────────────────────────
                // 2. المواصفات الفنية للكرت
                // ──────────────────────────────────────────────────────────
                const CustomSectionHeading(
                  icon: Icons.tune_rounded,
                  title: 'المواصفات الفنية للكرت',
                  subtitle: 'سعة نقل البيانات، مدة الاتصال النشط، والصلاحية الكلية للكرت.',
                ),
                AppSpacing.vSm,

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.balanceController,
                        label: 'حجم الرصيد',
                        hint: 'مثال: 5120',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      child: CustomDropdown<DataSizeUnit>(
                        label: 'الوحدة',
                        searchEnabled: false,
                        valueListenable: controller.selectedBalanceUnit,
                        items: DataSizeUnit.values.map((unit) {
                          return DropdownItem<DataSizeUnit>(
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.uptimeController,
                        label: 'وقت الاستخدام النشط',
                        hint: 'مثال: 24',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      child: CustomDropdown<TimeDurationUnit>(
                        label: 'الوحدة',
                        searchEnabled: false,
                        valueListenable: controller.selectedUptimeUnit,
                        items: TimeDurationUnit.values.map((unit) {
                          return DropdownItem<TimeDurationUnit>(
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.validityController,
                        label: 'فترة الصلاحية الكلية',
                        hint: 'مثال: 7',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        isRequired: false,
                        validator: FormValidators.doubleValidator(
                          fieldName: 'فترة الصلاحية',
                          isRequired: false,
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      flex: 2,
                      child: CustomDropdown<TimeDurationUnit>(
                        label: 'الوحدة',
                        searchEnabled: false,
                        valueListenable: controller.selectedValidityUnit,
                        items: TimeDurationUnit.values.map((unit) {
                          return DropdownItem<TimeDurationUnit>(
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

                CustomTextField(
                  controller: controller.voucherCountController,
                  label: 'عدد الكروت في الباقة (Voucher Count)',
                  hint: 'افتراضي: 51 كرت',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.numbers_rounded),
                  isRequired: true,
                  validator: FormValidators.integerValidator(
                    fieldName: 'عدد الكروت في الباقة',
                    isRequired: true,
                    minValue: 1,
                  ),
                ),

                AppSpacing.vLg,

                // ──────────────────────────────────────────────────────────
                // 3. التعرفة المالية والخصومات الافتراضية
                // ──────────────────────────────────────────────────────────
                const CustomSectionHeading(
                  icon: Icons.payments_outlined,
                  title: 'التعرفة المالية والخصومات الافتراضية',
                  subtitle: 'سعر البيع الأساسي ونسب الخصم التعاقدي للطلبات النقدية والآجلة.',
                ),
                AppSpacing.vSm,

                CustomTextField(
                  controller: controller.priceController,
                  label: 'السعر الأساسي للكرت (Base Price)',
                  hint: 'مثال: 1000',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  isRequired: true,
                  validator: FormValidators.amountValidator(
                    fieldName: 'السعر الأساسي للكرت',
                    isRequired: true,
                    minValue: 0,
                  ),
                ),

                AppSpacing.vSm,

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.cashDiscountController,
                        label: 'الخصم النقدي الافتراضي %',
                        hint: 'مثال: 10.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

                AppSpacing.vLg,

                // ──────────────────────────────────────────────────────────
                // 4. حالة تفعيل الباقة عبر المكون الموحد CustomSwitchListTile
                // ──────────────────────────────────────────────────────────
                const CustomSectionHeading(
                  icon: Icons.power_settings_new_rounded,
                  title: 'حالة تفعيل الباقة',
                  subtitle: 'التحكم في إتاحة الباقة لطلبات التوريد والشراء لنقاط البيع.',
                ),
                AppSpacing.vSm,

                CustomSwitchListTile(
                  title: controller.packageActiveStatus.value
                      ? 'الباقة مفعلة ونشطة'
                      : 'الباقة معطلة وموقوفة',
                  subtitle: controller.packageActiveStatus.value
                      ? 'تظهر في قائمة الشراء المتاحة لنقاط البيع'
                      : 'مخفية من قوائم الشراء الجديدة لنقاط البيع',
                  value: controller.packageActiveStatus.value,
                  activeIcon: Icons.check_circle_rounded,
                  inactiveIcon: Icons.pause_circle_outline_rounded,
                  activeColor: colors.primary,
                  onChanged: (val) => controller.packageActiveStatus.value = val,
                ),

                AppSpacing.vXl,

                // ──────────────────────────────────────────────────────────
                // 5. زر الحفظ
                // ──────────────────────────────────────────────────────────
                CustomButton(
                  text: isEditing ? 'حفظ التعديلات' : 'إنشاء الباقة الآن',
                  icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                  loading: isSaving,
                  onPressed: isSaving ? null : controller.savePackage,
                ),

                AppSpacing.vMd,
              ],
            ),
          ),
        ),
      );
    });
  }
}
