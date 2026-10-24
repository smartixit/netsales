import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/presentation/controllers/register_pos_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';

/// بطاقة إدخال بيانات نقطة البيع والموقع الجغرافي والشعار (PosInfoCard)
class PosInfoCard extends StatelessWidget {
  final RegisterPosController controller;

  const PosInfoCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                color: colors.primary,
                size: 20.r,
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'بيانات نقطة البيع والموقع',
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vMd,

          // منتقي شعار أو واجهة نقطة البيع (CustomImagePicker.logo)
          CustomImagePicker.logo(
            label: 'شعار أو واجهة نقطة البيع',
            hint: 'PNG, JPG حتى 2MB (اختياري)',
            valueListenable: controller.posLogo,
          ),

          AppSpacing.vMd,

          // اسم نقطة البيع
          CustomTextField(
            controller: controller.posNameController,
            label: 'اسم نقطة البيع / المحل *',
            hint: 'مثال: سوبرماركت الأمانة / مركز النور',
            prefixIcon: Icon(Icons.store_outlined, size: 20.r),
            validator: FormValidators.required(fieldName: 'اسم نقطة البيع'),
          ),

          AppSpacing.vMd,

          // اختيار المحافظة (CustomDropdown)
          Obx(() {
            final items = controller.governorates.map((gov) {
              return DropdownItem<GovernorateEntity>(
                value: gov,
                child: Text(
                  gov.governorateName,
                  style: AppTypography.bodyMedium,
                ),
              );
            }).toList();

            return CustomDropdown<GovernorateEntity>(
              label: 'المحافظة *',
              hint: controller.isLoadingGovernorates.value
                  ? 'جاري جلب المحافظات...'
                  : 'اختر المحافظة',
              prefixIcon: Icons.map_outlined,
              items: items,
              valueListenable: controller.selectedGovernorate,
              itemSearchText: (gov) => gov.governorateName,
              onChanged: controller.onGovernorateChanged,
              validator: (gov) => gov == null ? 'يرجى اختيار المحافظة.' : null,
            );
          }),

          AppSpacing.vMd,

          // اختيار المديرية (CustomDropdown متتالي)
          Obx(() {
            final items = controller.directorates.map((dir) {
              return DropdownItem<DirectorateEntity>(
                value: dir,
                child: Text(
                  dir.directorateName,
                  style: AppTypography.bodyMedium,
                ),
              );
            }).toList();

            final hasGov = controller.selectedGovernorate.value != null;

            return CustomDropdown<DirectorateEntity>(
              label: 'المديرية *',
              hint: controller.isLoadingDirectorates.value
                  ? 'جاري جلب المديريات...'
                  : (hasGov ? 'اختر المديرية' : 'اختر المحافظة أولاً'),
              prefixIcon: Icons.location_city_outlined,
              enabled: hasGov && !controller.isLoadingDirectorates.value,
              items: items,
              valueListenable: controller.selectedDirectorate,
              itemSearchText: (dir) => dir.directorateName,
              onChanged: controller.onDirectorateChanged,
              validator: (dir) => dir == null ? 'يرجى اختيار المديرية.' : null,
            );
          }),

          AppSpacing.vMd,

          // العنوان التفصيلي لنقطة البيع
          CustomTextField(
            controller: controller.posAddressController,
            label: 'العنوان التفصيلي',
            hint: 'مثال: الشارع العام، بجوار مسجد الفاروق',
            prefixIcon: Icon(Icons.place_outlined, size: 20.r),
            validator: FormValidators.addressValidator(
              fieldName: 'عنوان نقطة البيع',
              isRequired: false,
            ),
          ),

          AppSpacing.vMd,

          // البريد الإلكتروني لنقطة البيع (اختياري)
          CustomTextField(
            controller: controller.posEmailController,
            label: 'البريد الإلكتروني لنقطة البيع',
            hint: 'pos@example.com',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20.r),
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.emailValidator(
              fieldName: 'بريد نقطة البيع',
              isRequired: false,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms);
  }
}
