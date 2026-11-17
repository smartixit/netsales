import 'package:flutter/material.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/workspace/presentation/models/workspace_transaction_item_view_model.dart';

/// Converts POS-scoped invoices and procurement requests into dashboard rows.
class PosWorkspaceTransactionMapper {
  const PosWorkspaceTransactionMapper._();

  static List<WorkspaceTransactionItemViewModel> map({
    required Iterable<InvoiceEntity> invoices,
    required Iterable<RequestEntity> requests,
    required void Function(InvoiceEntity invoice) onOpenInvoice,
    required void Function(RequestEntity request) onOpenRequest,
  }) {
    return [
      ...invoices.map((invoice) => _mapInvoice(invoice, onOpenInvoice)),
      ...requests.map((request) => _mapRequest(request, onOpenRequest)),
    ];
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
          '- ${AmountFormatter.formatValue(invoice.invoiceTotalAmount)} ر.ي',
      amountColor: const Color(0xFFDC2626),
      statusPresentation: EnumPresentationRegistry.resolveInvoicePaymentStatus(
        invoice.paymentStatus,
        serverLabel: invoice.paymentStatusLabel,
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
    final reference = _shortReference(request.requestUuid, 'طلب توريد');

    return WorkspaceTransactionItemViewModel(
      title: 'طلب توريد',
      reference: reference,
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
