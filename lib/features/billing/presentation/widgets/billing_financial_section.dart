import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_cursor_page_state.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/dividers/custom_divider.dart';
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
    final decimalPlaces = (currency['decimal_places'] as num?)?.toInt() ?? 2;
    final rawPaymentMethod = row['payment_method'];
    final paymentMethod = rawPaymentMethod is Map
        ? Map<String, dynamic>.from(rawPaymentMethod)
        : const <String, dynamic>{};
    final metadata = <String>[
      if (row['invoice_number'] != null)
        'الفاتورة: ${row['invoice_number']}',
      if (paymentMethod['name'] != null) paymentMethod['name'].toString(),
      if (row['external_reference'] != null &&
          row['external_reference'].toString().isNotEmpty)
        'مرجع التحويل: ${row['external_reference']}',
      if (row['reason'] != null && row['reason'].toString().isNotEmpty)
        row['reason'].toString(),
      if (row['received_at'] != null)
        'تاريخ الاستلام: ${row['received_at']}',
      if (row['issued_at'] != null) 'تاريخ الإصدار: ${row['issued_at']}',
      if (row['processed_at'] != null)
        'تاريخ المعالجة: ${row['processed_at']}',
      if (row['verified_at'] != null)
        'تاريخ الاعتماد: ${row['verified_at']}',
    ];

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInfoListTile(
            title: Text(row[referenceKey]?.toString() ?? fallbackTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BillingStatusBadge(
                  status: row['status']?.toString(),
                  serverLabel: row['status_label']?.toString(),
                ),
                if (metadata.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(metadata.join(' · ')),
                ],
              ],
            ),
          ),
          const CustomDivider(extent: 1),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 10),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CustomInteractiveAmountText(
                amount: row[amountKey] ?? '—',
                currencyCode: currencyCode,
                decimalPlaces: decimalPlaces,
                enableTooltip: false,
                trailingText: currencyCode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
