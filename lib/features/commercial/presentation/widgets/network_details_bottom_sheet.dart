import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// نافذة استعراض وتحديث بيانات شبكة المزود
class NetworkDetailsBottomSheet {
  NetworkDetailsBottomSheet._();

  static Future<void> show({
    required NetworkEntity network,
    bool canEdit = false,
  }) {
    final formKey = GlobalKey<FormState>();
    final controller = Get.find<CommercialDirectoryController>();

    final nameController = TextEditingController(text: network.networkName);
    final phoneController = TextEditingController(
      text: network.networkPhoneNumber,
    );
    final addressController = TextEditingController(
      text: network.networkAddress ?? '',
    );
    final isEditing = false.obs;

    return CustomBottomSheet.show<void>(
      title: 'بيانات شبكة المزود',
      subtitle: 'المعلومات المؤسسية والتجارية لشبكة المزود',
      leadingIcon: Icons.hub_rounded,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vMd,

            // شارة الحالة ورقم الشبكة
            Builder(
              builder: (context) {
                final colors = context.colors;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 20.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hSm,
                          Text(
                            'معرف الشبكة #${network.networkUuid}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      CustomStatusBadge.fromPresentation(
                        EnumPresentationRegistry.resolveNetworkStatus(
                          network.typedStatus,
                          serverLabel: network.statusLabel,
                        ),
                        showDot: true,
                        isCompact: true,
                      ),
                    ],
                  ),
                );
              },
            ),

            AppSpacing.vMd,

            // اسم الشبكة
            Obx(
              () => CustomTextField(
                controller: nameController,
                label: 'اسم الشبكة',
                hint: 'أدخل الاسم الرسمي للشبكة',
                prefixIcon: const Icon(Icons.business_rounded),
                readOnly: !isEditing.value && !canEdit,
                isRequired: isEditing.value,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'اسم الشبكة مطلوب';
                  }
                  return null;
                },
              ),
            ),

            AppSpacing.vSm,

            // رقم الهاتف
            Obx(
              () => CustomTextField(
                controller: phoneController,
                label: 'رقم هاتف الشبكة',
                hint: '77xxxxxxx',
                prefixIcon: const Icon(Icons.phone_rounded),
                readOnly: !isEditing.value && !canEdit,
                isRequired: isEditing.value,
                keyboardType: TextInputType.phone,
              ),
            ),

            AppSpacing.vSm,

            // العنوان
            Obx(
              () => CustomTextField(
                controller: addressController,
                label: 'العنوان الجغرافي / المركز الرئيسي',
                hint: 'المدينة، الشارع، المبنى',
                prefixIcon: const Icon(Icons.location_on_outlined),
                readOnly: !isEditing.value && !canEdit,
                isRequired: false,
              ),
            ),

            AppSpacing.vLg,

            // أزرار الحفظ أو التعديل
            if (canEdit)
              Obx(() {
                if (!isEditing.value) {
                  return CustomButton.outline(
                    text: 'تعديل البيانات',
                    icon: Icons.edit_note_rounded,
                    onPressed: () => isEditing.value = true,
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: CustomButton.outline(
                        text: 'إلغاء',
                        onPressed: () {
                          nameController.text = network.networkName;
                          phoneController.text = network.networkPhoneNumber;
                          addressController.text = network.networkAddress ?? '';
                          isEditing.value = false;
                        },
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: CustomButton.primary(
                        text: 'حفظ التعديلات',
                        icon: Icons.check_rounded,
                        loading: controller.isActionLoading.value,
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final success = await controller.updateNetworkDetails(
                            network.networkId,
                            {
                              'network_name': nameController.text.trim(),
                              'network_phone_number': phoneController.text
                                  .trim(),
                              'network_address': addressController.text.trim(),
                            },
                          );
                          if (success) {
                            Get.back<void>();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),

            AppSpacing.vSm,
          ],
        ),
      ),
    );
  }
}
