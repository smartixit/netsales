import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/form_validators.dart';
import 'package:netsales/features/auth/domain/entities/directorate_entity.dart';
import 'package:netsales/features/auth/domain/entities/governorate_entity.dart';
import 'package:netsales/features/auth/presentation/controllers/register_network_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/pickers/custom_image_picker.dart';

/// بطاقة إدخال بيانات الشبكة والموقع الجغرافي والشعار (NetworkInfoCard)
class NetworkInfoCard extends GetView<RegisterNetworkController> {
  const NetworkInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // رأس القسم مع مؤشر الخطوة
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  color: colors.primary,
                  size: 20.r,
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'بيانات الشبكة والموقع',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    AppSpacing.vXxs,
                    Text(
                      'المعلومات الأساسية وموقع التغطية',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'الخطوة 1 من 2',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vLg,

          // منتقي شعار الشبكة المؤسسي
          CustomImagePicker.logo(
            label: 'شعار الشبكة',
            hint: 'PNG, JPG حتى 2MB (اختياري)',
            valueListenable: controller.networkLogo,
          ),

          AppSpacing.vMd,

          // اسم الشبكة
          CustomTextField(
            controller: controller.networkNameController,
            label: 'اسم الشبكة *',
            hint: 'مثال: شبكة النور اللاسلكية',
            prefixIcon: Icon(Icons.wifi_rounded, size: 20.r),
            validator: FormValidators.required(fieldName: 'اسم الشبكة'),
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

          // العنوان التفصيلي للشبكة
          CustomTextField(
            controller: controller.networkAddressController,
            label: 'العنوان التفصيلي',
            hint: 'مثال: الشارع العام، بجوار البريد',
            prefixIcon: Icon(Icons.place_outlined, size: 20.r),
            validator: FormValidators.addressValidator(
              fieldName: 'عنوان الشبكة',
              isRequired: false,
            ),
          ),

          AppSpacing.vMd,

          // البريد الإلكتروني للشبكة (اختياري)
          CustomTextField(
            controller: controller.networkEmailController,
            label: 'البريد الإلكتروني للشبكة',
            hint: 'info@network.com',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20.r),
            keyboardType: TextInputType.emailAddress,
            validator: FormValidators.emailValidator(
              fieldName: 'بريد الشبكة',
              isRequired: false,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppMotion.normal)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AppMotion.normal,
          curve: AppMotion.emphasized,
        );
  }
}
