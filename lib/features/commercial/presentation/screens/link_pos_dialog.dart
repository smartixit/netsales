import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// نافذة ربط نقطة بيع جديدة بشبكة المزود
/// معيار Clean Architecture و GetX - خالية تماماً من StatefulWidget أو setState
class LinkPosDialog {
  LinkPosDialog._();

  static Future<bool?> show({required int networkId}) {
    final formKey = GlobalKey<FormState>();
    final controller = Get.find<CommercialDirectoryController>();
    controller.posIdentifierController.clear();
    controller.linkStatusInitial.value = true;

    return CustomBottomSheet.show<bool>(
      title: 'ربط نقطة بيع جديدة',
      subtitle: 'أدخل المعرف الفريد (UUID) أو رقم نقطة البيع لربطها بشبكتك',
      leadingIcon: Icons.add_link_rounded,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSpacing.vMd,

            // حقل إدخال المعرف أو الرقم الموحد
            CustomTextField(
              controller: controller.posIdentifierController,
              label: 'معرف أو رقم نقطة البيع',
              hint: 'مثال: POS-2611-00001-A1B2 أو 12',
              prefixIcon: const Icon(Icons.qr_code_rounded),
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال معرف أو رقم نقطة البيع';
                }
                return null;
              },
            ),

            AppSpacing.vMd,

            // مفتاح التفعيل الأولي
            Builder(
              builder: (context) {
                final colors = context.colors;
                return Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              controller.linkStatusInitial.value
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.block_flipped,
                              color: controller.linkStatusInitial.value
                                  ? colors.primary
                                  : colors.error,
                              size: 20.r,
                            ),
                            AppSpacing.hSm,
                            Text(
                              'حالة الارتباط الأولية',
                              style: AppTypography.bodyMedium.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: controller.linkStatusInitial.value,
                          activeTrackColor: colors.primary,
                          onChanged: (val) {
                            controller.linkStatusInitial.value = val;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            AppSpacing.vLg,

            // زر تأكيد الربط الموحد
            GetX<CommercialDirectoryController>(
              builder: (ctrl) {
                return CustomButton.primary(
                  text: 'تأكيد وربط نقطة البيع',
                  icon: Icons.link_rounded,
                  loading: ctrl.isActionLoading.value,
                  onPressed: ctrl.isActionLoading.value
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          final input = ctrl.posIdentifierController.text.trim();
                          final isNumeric = int.tryParse(input) != null;
                          final int? posId = isNumeric ? int.parse(input) : null;
                          final String? posUuid = isNumeric ? null : input;

                          final success = await ctrl.linkPos(
                            networkId: networkId,
                            posId: posId,
                            posUuid: posUuid,
                            status: ctrl.linkStatusInitial.value,
                          );

                          if (success) {
                            Get.back(result: true);
                          }
                        },
                );
              },
            ),

            AppSpacing.vSm,
          ],
        ),
      ),
    );
  }
}
