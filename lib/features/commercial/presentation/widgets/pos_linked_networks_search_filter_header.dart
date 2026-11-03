import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/features/commercial/presentation/controllers/commercial_directory_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// شريط البحث والفلترة العلوية للشبكات المزودة المرتبطة بنقطة البيع
class PosLinkedNetworksSearchFilterHeader
    extends GetView<CommercialDirectoryController> {
  const PosLinkedNetworksSearchFilterHeader({super.key});

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
            label: 'البحث عن شبكة مزودة',
            hint: 'ابحث باسم الشبكة أو هاتفها...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: Obx(() {
              return controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink();
            }),
            isRequired: false,
            onChanged: controller.setSearchQuery,
          ),

          AppSpacing.vSm,

          // 2. شريط التبويب القطاعي لفلترة الحالة
          Obx(() {
            final activeFilter = controller.selectedStatusFilter.value;
            final selectedIndex = activeFilter == null
                ? 0
                : activeFilter
                ? 1
                : 2;

            final allCount = controller.links.length;
            final activeCount = controller.links.where((l) => l.status).length;
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
                  icon: Icons.check_circle_rounded,
                ),
                CustomSegmentItem(
                  label: 'معطلة',
                  count: inactiveCount,
                  icon: Icons.cancel_rounded,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
