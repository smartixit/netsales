import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/lists/custom_collection_filter_state.dart';

class BillingFinancialSection extends StatelessWidget {
  const BillingFinancialSection({
    required this.title,
    required this.emptyTitle,
    required this.page,
    required this.onLoadMore,
    required this.loadMoreLabel,
    required this.referenceKey,
    required this.fallbackTitle,
    required this.amountKey,
    required this.filterState,
    this.statusOptions = const [],
    required this.onSearchChanged,
    this.onStatusChanged,
    required this.onRefresh,
    this.searchHint,
    super.key,
  });

  final String title;
  final String emptyTitle;
  final BillingCursorPageState page;
  final VoidCallback onLoadMore;
  final String loadMoreLabel;
  final String referenceKey;
  final String fallbackTitle;
  final String amountKey;
  final CustomCollectionFilterState filterState;
  final List<DropdownItem<String>> statusOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?>? onStatusChanged;
  final VoidCallback onRefresh;
  final String? searchHint;

  @override
  Widget build(BuildContext context) {
    return BillingCursorCollectionSection(
      title: title,
      emptyTitle: emptyTitle,
      page: page,
      itemBuilder: _tile,
      onLoadMore: onLoadMore,
      loadMoreLabel: loadMoreLabel,
      filterState: filterState,
      statusOptions: statusOptions,
      onSearchChanged: onSearchChanged,
      onStatusChanged: onStatusChanged,
      onRefresh: onRefresh,
      searchHint: searchHint,
    );
  }

  Widget _tile(Map<String, dynamic> row) {
    final rawCurrency = row['currency'];
    final currency = rawCurrency is Map
        ? Map<String, dynamic>.from(rawCurrency)
        : const <String, dynamic>{};
    final currencyCode = currency['code']?.toString();
    final decimalPlaces =
        (currency['decimal_places'] as num?)?.toInt() ?? 2;

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
        title: Text(row[referenceKey]?.toString() ?? fallbackTitle),
        subtitle: BillingStatusBadge(status: row['status']?.toString()),
        trailing: CustomInteractiveAmountText(
          amount: row[amountKey] ?? '—',
          currencyCode: currencyCode,
          decimalPlaces: decimalPlaces,
          enableTooltip: false,
          trailingText: currencyCode,
        ),
      ),
    );
  }
}
