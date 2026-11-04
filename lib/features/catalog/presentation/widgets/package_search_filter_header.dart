import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/catalog/presentation/controllers/package_catalog_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شريط البحث والفلترة القطاعية لكتالوج باقات الكروت
class PackageSearchFilterHeader extends GetView<PackageCatalogController> {
  const PackageSearchFilterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        children: [
          // 1. حقل البحث
          CustomTextField(
            controller: controller.searchController,
            label: 'البحث في كتالوج الباقات',
            hint: 'ابحث باسم الباقة، السعر، أو حجم الرصيد...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Obx(() {
              return controller.searchQuery.value.isNotEmpty
                  ? CustomButton.icon(
                      icon: Icons.clear_rounded,
                      tooltip: 'مسح البحث',
                      dimension: 36.r,
                      iconSize: 18.r,
                      backgroundColor: Colors.transparent,
                      onPressed: () => controller.searchController.clear(),
                    )
                  : const SizedBox.shrink();
            }),
            isRequired: false,
          ),

          AppSpacing.vSm,

          // 2. شريط التبويب القطاعي الموحد لفلترة حالة الباقة
          Obx(() {
            final activeFilter = controller.statusFilter.value;
            final selectedIndex = activeFilter == null
                ? 0
                : activeFilter
                    ? 1
                    : 2;

            final allCount = controller.packages.length;
            final activeCount =
                controller.packages.where((p) => p.status).length;
            final inactiveCount = allCount - activeCount;

            return CustomSegmentedBar(
              selectedIndex: selectedIndex,
              onSegmentChanged: (index) {
                if (index == 0) {
                  controller.setStatusFilter(null);
                } else if (index == 1) {
                  controller.setStatusFilter(true);
                } else {
                  controller.setStatusFilter(false);
                }
              },
              items: [
                CustomSegmentItem(
                  label: 'الكل',
                  count: allCount,
                  icon: Icons.list_alt_rounded,
                ),
                CustomSegmentItem(
                  label: 'نشطة',
                  count: activeCount,
                  icon: Icons.check_circle_outline_rounded,
                ),
                CustomSegmentItem(
                  label: 'معطلة',
                  count: inactiveCount,
                  icon: Icons.pause_circle_outline_rounded,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

