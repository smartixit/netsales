import 'package:flutter/material.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_collection_status_options.dart';

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
    final remainingMinor =
        int.tryParse(invoice['remaining_minor']?.toString() ?? '0') ?? 0;
    final rawCurrency = invoice['currency'];
    final currency = rawCurrency is Map
        ? Map<String, dynamic>.from(rawCurrency)
        : const <String, dynamic>{};
    final currencyCode = currency['code']?.toString();
    final decimalPlaces =
        (currency['decimal_places'] as num?)?.toInt() ?? 2;
    final canPay = remainingMinor > 0 &&
        invoice['status'] != 'PAID' &&
        invoice['status'] != 'VOID' &&
        invoiceId != null;

    return CustomSurfaceCard(
      margin: const EdgeInsets.all(4),
      padding: EdgeInsets.zero,
      child: CustomInfoListTile(
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
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomInteractiveAmountText(
              amount: invoice['total'] ?? '—',
              currencyCode: currencyCode,
              decimalPlaces: decimalPlaces,
              enableTooltip: false,
              trailingText: currencyCode,
            ),
            if (canPay)
              CustomButton.primary(
                text: 'تسجيل دفعة',
                onPressed: () => BillingDialogs.payInvoice(controller, invoice),
              ),
          ],
        ),
      ),
    );
  }
}
