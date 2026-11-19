import 'package:flutter/material.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_option.dart';

/// ترويسة البحث والتصفية لدليل الشركاء والعلاقات التجارية المعتمدة على [CustomSearchFilterBar]
class CommercialSearchFilterHeader extends StatelessWidget {
  const CommercialSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearSearch,
    this.searchHint = 'بحث بالاسم، رقم الهاتف، أو الرمز التعريفي...',
  });

  final TextEditingController searchController;
  final String searchQuery;
  final bool? selectedStatus;
  final ValueChanged<bool?> onStatusChanged;
  final VoidCallback onClearSearch;
  final String searchHint;

  static const _statusOptions = <CustomSearchFilterOption<bool?>>[
    CustomSearchFilterOption<bool?>(
      label: 'كافة الشركاء',
      value: null,
      icon: Icons.all_inbox_rounded,
    ),
    CustomSearchFilterOption<bool?>(
      label: 'ارتباط نشط',
      value: true,
      icon: Icons.check_circle_rounded,
    ),
    CustomSearchFilterOption<bool?>(
      label: 'ارتباط مجمد',
      value: false,
      icon: Icons.pause_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterBar<bool?>(
      searchController: searchController,
      searchQuery: searchQuery,
      searchHint: searchHint,
      onClearSearch: onClearSearch,
      filterOptions: _statusOptions,
      selectedFilter: selectedStatus,
      onFilterChanged: onStatusChanged,
      filterSheetTitle: 'تصفية الشركاء',
      filterSheetSubtitle: 'اختر حالة النشاط التجاري التي ترغب في استعراضها',
      filterButtonTooltip: 'تصفية حسب حالة النشاط',
    );
  }
}
