import 'package:flutter/material.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// ترويسة البحث والتصفية لفواتير المبيعات والمشتريات المعتمدة على [CustomSearchFilterBar]
class InvoicesSearchFilterHeader extends StatelessWidget {
  const InvoicesSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
    this.searchHint = 'بحث برقم الفاتورة، UUID، أو اسم الطرف التجاري...',
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearSearch;
  final String searchHint;

  static const _statusOptions = <CustomSearchFilterOption<String>>[
    CustomSearchFilterOption<String>(
      label: 'كافة الفواتير',
      value: null,
      icon: Icons.all_inbox_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'مسددة بالكامل',
      value: 'PAID',
      icon: Icons.check_circle_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'سداد جزئي',
      value: 'PARTIALLY_PAID',
      icon: Icons.pie_chart_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'غير مسددة',
      value: 'UNPAID',
      icon: Icons.error_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterBar<String>(
      searchController: searchController,
      searchQuery: searchQuery,
      searchHint: searchHint,
      onClearSearch: onClearSearch,
      filterOptions: _statusOptions,
      selectedFilter: selectedStatus,
      onFilterChanged: onStatusChanged,
      filterSheetTitle: 'تصفية الفواتير',
      filterSheetSubtitle: 'اختر حالة السداد المالي التي ترغب في استعراضها',
      filterButtonTooltip: 'تصفية حسب حالة السداد',
    );
  }
}
