import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';

/// Maps invoice and procurement activity into one globally chronological list.
class PosWorkspaceTransactionMapper {
  const PosWorkspaceTransactionMapper._();

  static List<WorkspaceTransactionItemViewModel> map({
    required Iterable<InvoiceEntity> invoices,
    required Iterable<RequestEntity> requests,
    required void Function(InvoiceEntity invoice) onOpenInvoice,
    required void Function(RequestEntity request) onOpenRequest,
  }) {
    final entries = <({DateTime? date, WorkspaceTransactionItemViewModel item})>[];

    for (final invoice in invoices) {
      entries.add((
        date: DateFormatter.tryParse(
          invoice.invoiceDate ?? invoice.createdAt ?? '',
        ),
        item: _mapInvoice(invoice, onOpenInvoice),
      ));
    }

    for (final request in requests) {
      entries.add((
        date: DateFormatter.tryParse(
          request.requestDate ?? request.createdAt ?? '',
        ),
        item: _mapRequest(request, onOpenRequest),
      ));
    }

    entries.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return List.unmodifiable(entries.map((entry) => entry.item));
  }

  static WorkspaceTransactionItemViewModel _mapInvoice(
    InvoiceEntity invoice,
    void Function(InvoiceEntity invoice) onOpenInvoice,
  ) {
    final saleType = invoice.saleTypeLabel ?? 'شراء';
    final parsedDate = DateFormatter.tryParse(
      invoice.invoiceDate ?? invoice.createdAt ?? '',
    );
    final dateLabel = parsedDate == null ? '' : DateFormatter.smart(parsedDate);
    final reference = _shortReference(invoice.invoiceUuid, 'فاتورة توريد');
    final voucherDetail = invoice.totalVouchersCount > 0
        ? '${invoice.totalVouchersCount} كرت'
        : null;

    final subtitleParts = [
      saleType,
      if (dateLabel.isNotEmpty) dateLabel,
      ?voucherDetail,
    ];

    return WorkspaceTransactionItemViewModel(
      title: 'فاتورة توريد',
      reference: reference,
      subtitle: subtitleParts.join(' • '),
      formattedAmount:
          '- ${AmountFormatter.formatValue(invoice.invoiceTotalAmount)}',
      statusPresentation: const EnumPresentation(
        label: 'فاتورة',
        tone: SemanticTone.neutral,
      ),
      icon: Icons.inventory_2_rounded,
      onTap: () => onOpenInvoice(invoice),
    );
  }

  static WorkspaceTransactionItemViewModel _mapRequest(
    RequestEntity request,
    void Function(RequestEntity request) onOpenRequest,
  ) {
    final saleType = request.saleTypeLabel ?? 'طلب شراء';
    final parsedDate = DateFormatter.tryParse(
      request.requestDate ?? request.createdAt ?? '',
    );
    final dateLabel = parsedDate == null ? '' : DateFormatter.smart(parsedDate);

    return WorkspaceTransactionItemViewModel(
      title: 'طلب توريد',
      reference: _shortReference(request.requestUuid, 'طلب توريد'),
      subtitle: dateLabel.isEmpty ? saleType : '$saleType • $dateLabel',
      formattedAmount:
          '${AmountFormatter.formatValue(request.requestTotalAmount)} ر.ي',
      statusPresentation: EnumPresentationRegistry.resolveRequestStatus(
        request.status,
        serverLabel: request.statusLabel,
      ),
      icon: Icons.send_rounded,
      onTap: () => onOpenRequest(request),
    );
  }

  static String _shortReference(String? value, String fallback) {
    if (value == null || value.isEmpty) return fallback;
    return value.length > 8 ? value.substring(0, 8) : value;
  }
}
