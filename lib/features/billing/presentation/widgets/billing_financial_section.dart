import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingFinancialSection extends StatelessWidget {
  const BillingFinancialSection({
    required this.controller,
    required this.title,
    required this.emptyTitle,
    required this.page,
    required this.onLoadMore,
    required this.loadMoreLabel,
    required this.referenceKey,
    required this.fallbackTitle,
    required this.amountKey,
    super.key,
  });

  final BillingController controller;
  final String title;
  final String emptyTitle;
  final dynamic page;
  final VoidCallback onLoadMore;
  final String loadMoreLabel;
  final String referenceKey;
  final String fallbackTitle;
  final String amountKey;

  @override
  Widget build(BuildContext context) {
    return BillingCursorCollectionSection(
      title: title,
      emptyTitle: emptyTitle,
      page: page,
      itemBuilder: (row) => _tile(row),
      onLoadMore: onLoadMore,
      loadMoreLabel: loadMoreLabel,
    );
  }

  Widget _tile(Map<String, dynamic> row) {
    final currencyCode = row['currency_code']?.toString();
    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
        title: Text(row[referenceKey]?.toString() ?? fallbackTitle),
        subtitle: BillingStatusBadge(status: row['status']?.toString()),
        trailing: CustomInteractiveAmountText(
          amount: row[amountKey] ?? '—',
          currencyCode: currencyCode,
          enableTooltip: false,
          trailingText: currencyCode == null
              ? 'وحدة صغرى'
              : '$currencyCode · وحدة صغرى',
        ),
      ),
    );
  }
}
