import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/billing/presentation/widgets/billing_status_badge.dart';
import 'package:netsales/widgets/cards/custom_info_list_tile.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

class BillingInvoiceDetailsContent extends StatelessWidget {
  const BillingInvoiceDetailsContent({
    required this.invoice,
    super.key,
  });

  final Map<String, dynamic> invoice;

  @override
  Widget build(BuildContext context) {
    final rawCurrency = invoice['currency'];
    final currency = rawCurrency is Map
        ? Map<String, dynamic>.from(rawCurrency)
        : const <String, dynamic>{};
    final currencyCode = currency['code']?.toString();
    final decimalPlaces = (currency['decimal_places'] as num?)?.toInt() ?? 2;
    final rawLines = invoice['lines'];
    final lines = rawLines is List
        ? rawLines
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList(growable: false)
        : const <Map<String, dynamic>>[];
    final rawCreditNotes = invoice['credit_notes'];
    final creditNotes = rawCreditNotes is List
        ? rawCreditNotes
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList(growable: false)
        : const <Map<String, dynamic>>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomSurfaceCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice['invoice_number']?.toString() ?? 'فاتورة',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              BillingStatusBadge(
                status: invoice['status']?.toString(),
                serverLabel: invoice['status_label']?.toString(),
              ),
              const SizedBox(height: 14),
              _InvoiceDetailFact(
                label: 'تاريخ الإصدار',
                value: invoice['issued_on']?.toString() ?? '—',
              ),
              _InvoiceDetailFact(
                label: 'تاريخ الاستحقاق',
                value: invoice['due_on']?.toString() ?? '—',
              ),
              if (invoice['period_start'] != null ||
                  invoice['period_end'] != null)
                _InvoiceDetailFact(
                  label: 'فترة الفاتورة',
                  value:
                      '${invoice['period_start']?.toString() ?? '—'} – ${invoice['period_end']?.toString() ?? '—'}',
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 16, 4, 8),
          child: Text('ملخص المبالغ', style: AppTypography.titleMedium),
        ),
        CustomSurfaceCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              _InvoiceAmountRow(
                label: 'إجمالي الفاتورة',
                amount: invoice['total'] ?? '—',
                currencyCode: currencyCode,
                decimalPlaces: decimalPlaces,
              ),
              _InvoiceAmountRow(
                label: 'المدفوع المعتمد',
                amount: invoice['paid'] ?? '—',
                currencyCode: currencyCode,
                decimalPlaces: decimalPlaces,
              ),
              _InvoiceAmountRow(
                label: 'الإشعارات المطبقة',
                amount: invoice['credited_minor'] == null
                    ? '—'
                    : invoice['credited_minor'].toString(),
                currencyCode: currencyCode,
                decimalPlaces: decimalPlaces,
                minorAmount: true,
              ),
              _InvoiceAmountRow(
                label: 'الرصيد المتبقي',
                amount: invoice['remaining'] ?? '—',
                currencyCode: currencyCode,
                decimalPlaces: decimalPlaces,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 16, 4, 8),
          child: Text('بنود الفاتورة', style: AppTypography.titleMedium),
        ),
        if (lines.isEmpty)
          const CustomSurfaceCard(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(14),
            child: Text('لا توجد بنود مسجلة لهذه الفاتورة.'),
          )
        else
          ...lines.map(
            (line) => CustomSurfaceCard(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomInfoListTile(
                title: Text(line['description']?.toString() ?? 'بند فاتورة'),
                subtitle: Text(
                  '${line['line_type']?.toString() ?? '—'} · الكمية ${line['quantity']?.toString() ?? '—'}',
                ),
                trailing: CustomInteractiveAmountText(
                  amount: line['total'] ?? '—',
                  currencyCode: currencyCode,
                  decimalPlaces: decimalPlaces,
                  enableTooltip: false,
                  trailingText: currencyCode,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4, 16, 4, 8),
          child: Text('الإشعارات الدائنة', style: AppTypography.titleMedium),
        ),
        if (creditNotes.isEmpty)
          const CustomSurfaceCard(
            margin: EdgeInsets.all(4),
            padding: EdgeInsets.all(14),
            child: Text('لا توجد إشعارات دائنة مرتبطة بهذه الفاتورة.'),
          )
        else
          ...creditNotes.map(
            (note) => CustomSurfaceCard(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomInfoListTile(
                title: Text(
                  note['credit_note_number']?.toString() ?? 'إشعار دائن',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note['status']?.toString() ?? '—'),
                    if (note['issued_at'] != null)
                      Text(note['issued_at'].toString()),
                  ],
                ),
                trailing: CustomInteractiveAmountText(
                  amount: note['total'] ?? '—',
                  currencyCode: currencyCode,
                  decimalPlaces: decimalPlaces,
                  enableTooltip: false,
                  trailingText: currencyCode,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InvoiceDetailFact extends StatelessWidget {
  const _InvoiceDetailFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _InvoiceAmountRow extends StatelessWidget {
  const _InvoiceAmountRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.decimalPlaces,
    this.minorAmount = false,
  });

  final String label;
  final dynamic amount;
  final String? currencyCode;
  final int decimalPlaces;
  final bool minorAmount;

  @override
  Widget build(BuildContext context) {
    return CustomInfoListTile(
      title: Text(label),
      trailing: CustomInteractiveAmountText(
        amount: amount,
        currencyCode: currencyCode,
        decimalPlaces: decimalPlaces,
        enableTooltip: false,
        trailingText: currencyCode,
        isMinorUnit: minorAmount,
      ),
    );
  }
}
