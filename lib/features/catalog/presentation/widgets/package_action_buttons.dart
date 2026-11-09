import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_delete_confirm_dialog.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// أزرار الإجراءات الإدارية في شاشة تفاصيل الباقة (تعديل + تبديل الحالة)
class PackageActionButtons extends GetView<PackageCatalogController> {
  final PackageEntity package;

  const PackageActionButtons({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإجراءات الإدارية للباقة',
            style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vMd,
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'تعديل الباقة',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    controller.initEditForm(package);
                    Get.toNamed<void>(AppRoutes.packageForm);
                  },
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Obx(() {
                  return CustomButton.outline(
                    text: package.status ? 'تعطيل مؤقت' : 'تفعيل الباقة',
                    icon: package.status
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    onPressed: controller.isTogglingStatus.value
                        ? null
                        : () => controller.togglePackageStatus(package),
                    loading: controller.isTogglingStatus.value,
                  );
                }),
              ),
            ],
          ),
          AppSpacing.vSm,
          CustomButton.danger(
            text: 'حذف الباقة',
            icon: Icons.delete_outline_rounded,
            onPressed: () => PackageDeleteConfirmDialog.show(
              packageName: package.packageName,
              onConfirm: () async {
                final deleted = await controller.deletePackage(
                  package.packageId,
                );
                if (deleted) {
                  Get.back<void>();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
