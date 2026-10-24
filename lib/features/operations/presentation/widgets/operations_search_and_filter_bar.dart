import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/operations/presentation/controllers/operations_controller.dart';
import 'package:netsales/widgets/bars/custom_search_filter_bar.dart';

/// ============================================================================
/// شريط البحث والتصفية للعمليات (غلاف رشيق - Lean Feature Adapter)
/// ============================================================================
/// يربط متحكم العمليات [OperationsController] بالودجت العام المشترك [CustomSearchFilterBar].
class OperationsSearchAndFilterBar extends StatelessWidget {
  final OperationsController controller;

  const OperationsSearchAndFilterBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isInvoiceTab = controller.activeSegmentIndex.value == 0;

      final filterItems = isInvoiceTab
          ? const [
              CustomFilterItem<String>(label: 'الكل', value: 'ALL'),
              CustomFilterItem<String>(label: 'مبيعات نقدية', value: 'CASH'),
              CustomFilterItem<String>(label: 'مبيعات آجلة', value: 'CREDIT'),
              CustomFilterItem<String>(label: 'غير مسددة (مديونية)', value: 'UNPAID'),
            ]
          : const [
              CustomFilterItem<String>(label: 'كافة الطلبات', value: 'ALL'),
              CustomFilterItem<String>(label: 'بانتظار الاعتماد', value: 'PENDING'),
              CustomFilterItem<String>(label: 'طلبات معتمدة', value: 'APPROVED'),
              CustomFilterItem<String>(label: 'طلبات مرفوضة', value: 'REJECTED'),
            ];

      final selectedFilter = isInvoiceTab
          ? controller.selectedInvoiceFilter.value
          : controller.selectedRequestFilter.value;

      return CustomSearchFilterBar<String>(
        searchController: controller.searchController,
        searchLabel: 'البحث في العمليات',
        searchHint: 'ابحث برقم المرجع أو اسم نقطة البيع أو الشبكة...',
        onSearchClear: controller.clearSearch,
        onSearchSubmitted: controller.onSearchSubmitted,
        filterItems: filterItems,
        selectedFilter: selectedFilter,
        onFilterChanged: (filter) {
          if (isInvoiceTab) {
            controller.filterInvoices(filter);
          } else {
            controller.filterRequests(filter);
          }
        },
      );
    });
  }
}
