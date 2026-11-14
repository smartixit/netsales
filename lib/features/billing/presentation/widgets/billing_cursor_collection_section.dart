import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_bar.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_state.dart';
import 'package:netsales/widgets/feedback/custom_error_state.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_feed.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/lists/custom_cursor_load_more.dart';

/// Feature-level composition for one independently cursor-paginated billing
/// collection. The page state and row renderer remain owned by the caller.
class BillingCursorCollectionSection extends StatelessWidget {
  const BillingCursorCollectionSection({
    required this.title,
    required this.emptyTitle,
    required this.page,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.loadMoreLabel,
    this.filterState,
    this.statusOptions = const [],
    this.onSearchChanged,
    this.onStatusChanged,
    this.onRefresh,
    this.searchHint,
    super.key,
  });

  final String title;
  final String emptyTitle;
  final BillingCursorPageState page;
  final Widget Function(Map<String, dynamic> row) itemBuilder;
  final VoidCallback onLoadMore;
  final String loadMoreLabel;
  final CustomCollectionFilterState? filterState;
  final List<DropdownItem<String>> statusOptions;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String?>? onStatusChanged;
  final VoidCallback? onRefresh;
  final String? searchHint;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 8),
            child: Text(title, style: AppTypography.titleMedium),
          ),
          if (filterState != null && onSearchChanged != null)
            CustomCollectionFilterBar(
              state: filterState!,
              searchLabel: 'بحث',
              searchHint: searchHint ?? 'ابحث في $title',
              onSearchChanged: onSearchChanged!,
              statusOptions: statusOptions,
              onStatusChanged: onStatusChanged,
            ),
          if (page.firstPageError.value != null)
            CustomErrorState.compact(
              title: 'تعذر تحميل $title',
              subtitle: page.firstPageError.value,
              onRetry: onRefresh,
            ),
          if (page.items.isEmpty && page.isLoadingFirstPage.value)
            const CustomSkeletonFeed(itemCount: 2, shrinkWrap: true)
          else if (page.items.isEmpty && page.firstPageError.value == null)
            CustomEmptyState.compact(title: emptyTitle)
          else
            ...page.items.map(itemBuilder),
          CustomCursorLoadMore(
            hasMore: page.hasMore,
            isLoading: page.isLoadingMore.value,
            error: page.loadMoreError.value,
            onPressed: onLoadMore,
            label: loadMoreLabel,
          ),
        ],
      ),
    );
  }
}
