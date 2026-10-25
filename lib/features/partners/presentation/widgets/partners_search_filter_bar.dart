import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/bars/custom_search_filter_bar.dart';

/// ============================================================================
/// شريط البحث والتصفية للشركاء (PartnersSearchFilterBar)
/// ============================================================================
/// غلاف رشيق (Lean Feature Adapter) يربط [PartnersController] بـ [CustomSearchFilterBar].
class PartnersSearchFilterBar extends StatelessWidget {
  final PartnersController controller;

  const PartnersSearchFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLinksTab = controller.activeSegmentIndex.value == 2;

      final filterItems = isLinksTab
          ? const [
              CustomFilterItem<String>(label: 'كافة العقود', value: 'ALL'),
              CustomFilterItem<String>(label: 'عقود نشطة', value: 'ACTIVE'),
              CustomFilterItem<String>(label: 'عقود مجمدة', value: 'INACTIVE'),
            ]
          : const [
              CustomFilterItem<String>(label: 'الكل', value: 'ALL'),
              CustomFilterItem<String>(label: 'المفعّلة', value: 'ACTIVE'),
              CustomFilterItem<String>(label: 'قيد المراجعة', value: 'PENDING'),
              CustomFilterItem<String>(label: 'المعطلة', value: 'INACTIVE'),
              CustomFilterItem<String>(label: 'المرفوضة', value: 'REJECTED'),
            ];

      final searchHint = controller.activeSegmentIndex.value == 0
          ? 'ابحث باسم الشبكة، الهاتف، المالك، أو المنطقة...'
          : (controller.activeSegmentIndex.value == 1
              ? 'ابحث باسم نقطة البيع، الوكيل، الهاتف، أو المنطقة...'
              : 'ابحث باسم الشبكة أو نقطة البيع المرتبطة...');

      return CustomSearchFilterBar<String>(
        searchController: controller.searchController,
        searchLabel: 'البحث في الشركاء',
        searchHint: searchHint,
        onSearchClear: controller.clearSearch,
        onSearchSubmitted: controller.onSearchSubmitted,
        filterItems: filterItems,
        selectedFilter: controller.selectedStatusFilter.value,
        onFilterChanged: controller.filterByStatus,
      );
    });
  }
}
