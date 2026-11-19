import 'package:flutter/material.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// ترويسة البحث والتصفية لطلبات التوريد المعتمدة على المكون العام المستقل CustomSearchFilterBar
class ProcurementSearchFilterHeader extends StatelessWidget {
  const ProcurementSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearSearch;

  static const _statusOptions = <CustomSearchFilterOption<String>>[
    CustomSearchFilterOption<String>(
      label: 'كل الطلبات',
      value: null,
      icon: Icons.all_inbox_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'قيد المراجعة',
      value: 'PENDING',
      icon: Icons.hourglass_top_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'معتمدة',
      value: 'APPROVED',
      icon: Icons.check_circle_outline_rounded,
    ),
    CustomSearchFilterOption<String>(
      label: 'مرفوضة',
      value: 'REJECTED',
      icon: Icons.cancel_outlined,
    ),
    CustomSearchFilterOption<String>(
      label: 'ملغاة',
      value: 'CANCELLED',
      icon: Icons.block_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterBar<String>(
      searchController: searchController,
      searchQuery: searchQuery,
      searchHint: 'بحث برقم الطلب، اسم نقطة البيع أو الملاحظات...',
      onClearSearch: onClearSearch,
      filterOptions: _statusOptions,
      selectedFilter: selectedStatus,
      onFilterChanged: onStatusChanged,
      filterSheetTitle: 'تصفية طلبات التوريد',
      filterSheetSubtitle: 'اختر حالة الطلبات التي ترغب في استعراضها',
      filterButtonTooltip: 'تصفية حسب حالة الطلب',
    );
  }
}
