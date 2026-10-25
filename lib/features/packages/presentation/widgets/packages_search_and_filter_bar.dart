import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/packages/presentation/controllers/packages_controller.dart';
import 'package:netsales/widgets/bars/custom_search_filter_bar.dart';

/// ============================================================================
/// شريط البحث والتصفية الموحد لمركز الباقات (PackagesSearchAndFilterBar)
/// ============================================================================
class PackagesSearchAndFilterBar extends StatelessWidget {
  final PackagesController controller;

  const PackagesSearchAndFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Obx(
        () {
          final isPackagesTab = controller.activeSegmentIndex.value == 0;
          return CustomSearchFilterBar<String>(
            searchController: controller.searchController,
            searchHint: isPackagesTab
                ? 'ابحث باسم الباقة أو السعر...'
                : 'ابحث باسم نقطة البيع أو الباقة...',
            onSearchChanged: (val) {
              controller.packages.refresh();
              controller.discounts.refresh();
            },
            onSearchClear: () {
              controller.packages.refresh();
              controller.discounts.refresh();
            },
            selectedFilter: controller.selectedFilter.value,
            onFilterChanged: (val) {
              controller.updateFilter(val);
            },
            filterItems: const [
              CustomFilterItem(label: 'الكل', value: 'ALL'),
              CustomFilterItem(label: 'المفعلة', value: 'ACTIVE'),
              CustomFilterItem(label: 'المعطلة', value: 'INACTIVE'),
            ],
          );
        },
      ),
    );
  }
}
