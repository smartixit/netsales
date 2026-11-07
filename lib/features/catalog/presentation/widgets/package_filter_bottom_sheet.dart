import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ورقة سفلية لفلترة باقات الكتالوج بحسب الحالة المعتمدة على الخادم
class PackageFilterBottomSheet extends StatelessWidget {
  final PackageCatalogController controller;

  const PackageFilterBottomSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(PackageCatalogController controller) {
    return CustomBottomSheet.show<void>(
      title: 'فلترة باقات الكتالوج',
      child: PackageFilterBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final currentStatus = controller.statusFilter.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حالة الباقة على الخادم',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                CustomFilterChip(
                  label: 'الكل',
                  isSelected: currentStatus == null,
                  onSelected: () => controller.setStatusFilter(null),
                ),
                CustomFilterChip(
                  label: 'النشطة فقط',
                  isSelected: currentStatus == true,
                  onSelected: () => controller.setStatusFilter(true),
                ),
                CustomFilterChip(
                  label: 'المعطلة فقط',
                  isSelected: currentStatus == false,
                  onSelected: () => controller.setStatusFilter(false),
                ),
              ],
            ),
            AppSpacing.vXl,
            CustomButton(
              text: 'إغلاق',
              onPressed: () => Get.back<void>(),
            ),
            AppSpacing.vMd,
          ],
        ),
      );
    });
  }
}
