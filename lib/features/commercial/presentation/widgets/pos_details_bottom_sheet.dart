import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';
import 'package:netsales/widgets/toasts/custom_toast.dart';

/// نافذة استعراض وتحديث بيانات نقطة البيع
class PosDetailsBottomSheet {
  PosDetailsBottomSheet._();

  static Future<void> show({required PosEntity pos, bool canEdit = false}) {
    final formKey = GlobalKey<FormState>();
    final controller = Get.find<CommercialDirectoryController>();

    final nameController = TextEditingController(text: pos.posName);
    final phoneController = TextEditingController(text: pos.posPhoneNumber);
    final addressController = TextEditingController(text: pos.posAddress ?? '');
    final isEditing = false.obs;

    return CustomBottomSheet.show<void>(
      title: 'بيانات نقطة البيع',
      subtitle: 'المعلومات التجارية والتشغيلية لنقطة البيع',
      leadingIcon: Icons.storefront_rounded,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vMd,

            // المعرف الفريد UUID
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
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 20.r,
                        color: colors.primary,
                      ),
                      AppSpacing.hSm,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المعرف الفريد (UUID)',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              pos.posUuid,
                              style: AppTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomButton.icon(
                        icon: Icons.copy_rounded,
                        iconSize: 18.r,
                        dimension: 32.r,
                        tooltip: 'نسخ المعرف',
                        onPressed: () async {
                          await UrlLauncherService.copyToClipboard(pos.posUuid);
                          CustomToast.show(
                            message: 'تم نسخ معرف نقطة البيع',
                            icon: Icons.copy_rounded,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            AppSpacing.vMd,

            // حقل الاسم التجاري
            Obx(
              () => CustomTextField(
                controller: nameController,
                label: 'اسم نقطة البيع',
                hint: 'أدخل الاسم التجاري لنقطة البيع',
                prefixIcon: const Icon(Icons.store_rounded),
                readOnly: !isEditing.value && !canEdit,
                isRequired: isEditing.value,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'اسم نقطة البيع مطلوب';
                  }
                  return null;
                },
              ),
            ),

            AppSpacing.vSm,

            // حقل رقم الهاتف
            Obx(
              () => CustomTextField(
                controller: phoneController,
                label: 'رقم الهاتف',
                hint: '77xxxxxxx',
                prefixIcon: const Icon(Icons.phone_rounded),
                readOnly: !isEditing.value && !canEdit,
                isRequired: isEditing.value,
                keyboardType: TextInputType.phone,
              ),
            ),

            AppSpacing.vSm,

            // حقل العنوان
            Obx(
              () => CustomTextField(
                controller: addressController,
                label: 'العنوان / الموقع الجغرافي',
                hint: 'المدينة، الشارع، المعلم المجاور',
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
                          nameController.text = pos.posName;
                          phoneController.text = pos.posPhoneNumber;
                          addressController.text = pos.posAddress ?? '';
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
                          final success = await controller
                              .updatePosDetails(pos.posId, {
                                'pos_name': nameController.text.trim(),
                                'pos_phone_number': phoneController.text.trim(),
                                'pos_address': addressController.text.trim(),
                              });
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
