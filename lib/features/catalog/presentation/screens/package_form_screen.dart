import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/core/utils/package_spec_formatter.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_form_section_header.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_live_preview_card.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/foundation/custom_app_scaffold.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_switch_list_tile.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// شاشة إنشاء وتعديل باقة كروت الإنترنت — مسؤوليتها تركيب الصفحة فقط دون أي منطق أو دوال بناء خاصة
class PackageFormScreen extends GetView<PackageCatalogController> {
  const PackageFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final isEditing = controller.isEditing.value;
      final isSaving = controller.isSaving.value;

      return CustomAppScaffold(
        appBar: AppBar(
          title: Text(
            isEditing ? 'تعديل باقة الكروت' : 'إنشاء باقة كروت جديدة',
            style: AppTypography.titleMedium.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. البيانات التعريفية للباقة
                const PackageFormSectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: 'البيانات التعريفية للباقة',
                ),
                AppSpacing.vSm,

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

                Obx(() {
                  return CustomColorPicker(
                    label: 'لون الباقة المميز (Brand Color)',
                    selectedColorHex: controller.selectedColorHex.value,
                    onColorChanged: (newHex) {
                      controller.selectedColorHex.value = newHex;
                    },
                  );
                }),

                AppSpacing.vLg,

                // 2. المواصفات الفنية للكرت مع القوائم المنسدلة للوحدات والتحويل التلقائي
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

                // وقت الاستخدام + اختيار وحدة الوقت (دقيقة / ساعة / يوم)
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

                // مدة الصلاحية + اختيار وحدة الصلاحية (ساعة / يوم / أسبوع / شهر)
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
                        prefixIcon:
                            const Icon(Icons.calendar_today_outlined),
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

                CustomTextField(
                  controller: controller.voucherCountController,
                  label: 'عدد الكروت في الحزمة',
                  hint: 'الافتراضي: 1',
                  keyboardType: TextInputType.number,
                  prefixIcon:
                      const Icon(Icons.confirmation_number_outlined),
                  isRequired: false,
                  validator: FormValidators.integerValidator(
                    fieldName: 'عدد الكروت',
                    isRequired: false,
                  ),
                ),

                AppSpacing.vLg,

                // 3. التعرفة المالية والخصومات الافتراضية
                const PackageFormSectionHeader(
                  icon: Icons.payments_outlined,
                  title: 'التعرفة المالية والخصومات الافتراضية',
                ),
                AppSpacing.vSm,

                CustomTextField(
                  controller: controller.priceController,
                  label: 'السعر الأساسي للكرت (Base Price)',
                  hint: 'مثال: 1000',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.attach_money_rounded),
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
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

                // 4. بطاقة المعاينة الاسترشادية للأسعار الصافية
                const PackageLivePreviewCard(),

                AppSpacing.vLg,

                // 5. حالة تفعيل الباقة عبر CustomSwitchListTile الموحدة
                Obx(() {
                  final isActive = controller.packageActiveStatus.value;
                  return CustomSwitchListTile(
                    title: 'تفعيل الباقة فور الحفظ',
                    subtitle: isActive
                        ? 'الباقة ستكون متاحة مباشرة لطلب الوكلاء'
                        : 'الباقة ستكون معطلة ومخفية عن الوكلاء',
                    value: isActive,
                    activeIcon: Icons.check_circle_outline_rounded,
                    inactiveIcon: Icons.highlight_off_rounded,
                    activeColor: colors.success,
                    onChanged: (val) {
                      controller.packageActiveStatus.value = val;
                    },
                  );
                }),

                AppSpacing.vXl,

                // 6. زر الحفظ الرئيسي
                CustomButton(
                  text: isEditing ? 'حفظ التعديلات' : 'إنشاء الباقة الآن',
                  icon: isEditing ? Icons.save_rounded : Icons.add_rounded,
                  loading: isSaving,
                  onPressed: isSaving
                      ? null
                      : () async {
                          final ok = await controller.submitPackageForm();
                          if (ok) {
                            Get.back<void>();
                          }
                        },
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
