import 'package:flutter/material.dart';
import 'package:netsales/widgets/inputs/custom_search_filter_bar.dart';

/// ترويسة البحث والتصفية للمصروفات التشغيلية المعتمدة على [CustomSearchFilterBar]
class ExpensesSearchFilterHeader extends StatelessWidget {
  const ExpensesSearchFilterHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onClearSearch,
    this.searchHint = 'بحث برقم المصروف، بيان البند، أو التاريخ...',
  });

  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onClearSearch;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    return CustomSearchFilterBar<String>(
      searchController: searchController,
      searchQuery: searchQuery,
      searchHint: searchHint,
      onClearSearch: onClearSearch,
      filterOptions: const [],
    );
  }
}
