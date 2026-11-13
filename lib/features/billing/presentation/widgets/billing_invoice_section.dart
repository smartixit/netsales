import 'package:flutter/material.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/billing/presentation/controllers/billing_controller.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_cursor_collection_section.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_dialogs.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
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
    );
  }

  Widget _tile(Map<String, dynamic> invoice) {
    final invoiceId = (invoice['invoice_id'] as num?)?.toInt();
    final remaining =
        int.tryParse(invoice['remaining_minor']?.toString() ?? '0') ?? 0;
    final canPay = remaining > 0 &&
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
            Text(
              'المتبقي: ${AmountFormatter.format(remaining.toString())} وحدة صغرى',
            ),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomInteractiveAmountText(
              amount: invoice['total_minor'] ?? '—',
              currencyCode: invoice['currency_code']?.toString(),
              enableTooltip: false,
              trailingText: invoice['currency_code'] == null
                  ? 'وحدة صغرى'
                  : '${invoice['currency_code']} · وحدة صغرى',
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
