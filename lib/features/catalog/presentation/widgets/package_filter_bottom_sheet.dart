import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/badges/custom_filter_chip.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// ورقة سفلية لفلترة وترتيب باقات الكتالوج
class PackageFilterBottomSheet extends StatelessWidget {
  final PackageCatalogController controller;

  const PackageFilterBottomSheet({
    super.key,
    required this.controller,
  });

  static Future<void> show(PackageCatalogController controller) {
    return CustomBottomSheet.show<void>(
      title: 'فلترة وترتيب الباقات',
      child: PackageFilterBottomSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final currentStatus = controller.statusFilter.value;
      final currentSort = controller.sortOption.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حالة الباقة',
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

            AppSpacing.vLg,

            Text(
              'ترتيب حسب',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                CustomFilterChip(
                  label: 'الأحدث أولاً',
                  isSelected: currentSort == PackageSortOption.newest,
                  onSelected: () =>
                      controller.setSortOption(PackageSortOption.newest),
                ),
                CustomFilterChip(
                  label: 'الاسم (أ - ي)',
                  isSelected: currentSort == PackageSortOption.nameAsc,
                  onSelected: () =>
                      controller.setSortOption(PackageSortOption.nameAsc),
                ),
                CustomFilterChip(
                  label: 'السعر: الأقل أولاً',
                  isSelected: currentSort == PackageSortOption.priceAsc,
                  onSelected: () =>
                      controller.setSortOption(PackageSortOption.priceAsc),
                ),
                CustomFilterChip(
                  label: 'السعر: الأعلى أولاً',
                  isSelected: currentSort == PackageSortOption.priceDesc,
                  onSelected: () =>
                      controller.setSortOption(PackageSortOption.priceDesc),
                ),
              ],
            ),

            AppSpacing.vXl,

            CustomButton(
              text: 'تطبيق الفلاتر',
              onPressed: () => Get.back<void>(),
            ),
            AppSpacing.vMd,
          ],
        ),
      );
    });
  }
}
