import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';
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
    super.key,
  });

  final String title;
  final String emptyTitle;
  final BillingCursorPageState page;
  final Widget Function(Map<String, dynamic> row) itemBuilder;
  final VoidCallback onLoadMore;
  final String loadMoreLabel;

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
          if (page.items.isEmpty)
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
