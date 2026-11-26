import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_collection_status_options.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/dividers/custom_divider.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingInvoiceSection extends StatelessWidget {
  const BillingInvoiceSection({required this.controller, super.key});

  final BillingController controller;

  @override
  Widget build(BuildContext context) {
    return BillingCursorCollectionSection(
      title: 'الفواتير',
      emptyTitle: 'لا توجد فواتير',
      page: controller.invoicesPage,
      itemBuilder: _tile,
      onLoadMore: controller.loadMoreInvoices,
      loadMoreLabel: 'تحميل المزيد من الفواتير',
      filterState: controller.invoicesFilter,
      statusOptions: BillingCollectionStatusOptions.build(
        controller.invoicesFilter.statusValues,
      ),
      onSearchChanged: controller.searchInvoices,
      onStatusChanged: controller.setInvoiceStatus,
      onRefresh: controller.refreshInvoices,
      searchHint: 'ابحث برقم الفاتورة أو اسم الخطة',
    );
  }

  Widget _tile(Map<String, dynamic> invoice) {
    final invoiceId = (invoice['invoice_id'] as num?)?.toInt();
    final rawCurrency = invoice['currency'];
    final currency = rawCurrency is Map
        ? Map<String, dynamic>.from(rawCurrency)
        : const <String, dynamic>{};
    final currencyCode = currency['code']?.toString();
    final decimalPlaces = (currency['decimal_places'] as num?)?.toInt() ?? 2;
    final availableMinor =
        int.tryParse(invoice['available_to_submit_minor']?.toString() ?? '0') ??
        0;
    final canPay = invoice['can_submit_payment'] == true &&
        availableMinor > 0 &&
        invoiceId != null;

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomInfoListTile(
            title: Text(invoice['invoice_number']?.toString() ?? 'فاتورة'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BillingStatusBadge(
                  status: invoice['status']?.toString(),
                  serverLabel: invoice['status_label']?.toString(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('المتبقي: '),
                    CustomInteractiveAmountText(
                      amount: invoice['remaining'] ?? '—',
                      currencyCode: currencyCode,
                      decimalPlaces: decimalPlaces,
                      enableTooltip: false,
                      trailingText: currencyCode,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const CustomDivider(extent: 1),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 14, 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                CustomInteractiveAmountText(
                  amount: invoice['total'] ?? '—',
                  currencyCode: currencyCode,
                  decimalPlaces: decimalPlaces,
                  enableTooltip: false,
                  trailingText: currencyCode,
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (invoiceId != null)
                      CustomButton.text(
                        text: 'التفاصيل',
                        onPressed: () =>
                            BillingDialogs.invoiceDetails(controller, invoiceId),
                      ),
                    if (canPay)
                      CustomButton.primary(
                        text: 'تسجيل دفعة',
                        onPressed: () =>
                            BillingDialogs.payInvoice(controller, invoice),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
