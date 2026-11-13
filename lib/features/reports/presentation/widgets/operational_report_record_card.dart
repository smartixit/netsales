import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/invoice_payment_status.dart';
import 'package:netsales/core/enums/request_status.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/enums/repayment_status.dart';
import 'package:netsales/core/enums/receivable_aging_bucket.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/cards/custom_surface_card.dart';

class OperationalReportRecordCard extends StatelessWidget {
  const OperationalReportRecordCard({
    required this.record,
    required this.type,
    required this.currencyCode,
    super.key,
  });

  final OperationalReportRecord record;
  final OperationalReportType type;
  final String currencyCode;

  String _first(List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final value = record.textAt(key, fallback: '');
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  EnumPresentation _statusPresentation(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '—') {
      return EnumPresentation.unknown(fallbackLabel: 'غير متاح');
    }

    final presentation = switch (type) {
      OperationalReportType.sales =>
        EnumPresentationRegistry.resolveInvoicePaymentStatus(
          InvoicePaymentStatus.fromWire(normalized),
        ),
      OperationalReportType.networkWallet ||
      OperationalReportType.posWallet =>
        EnumPresentationRegistry.resolveWalletOperationType(
          WalletOperationType.fromWire(normalized),
        ),
      OperationalReportType.repayments =>
        EnumPresentationRegistry.resolveRepaymentStatus(
          RepaymentStatus.fromWire(normalized),
        ),
      OperationalReportType.requests =>
        EnumPresentationRegistry.resolveRequestStatus(
          RequestStatus.fromWire(normalized),
        ),
      OperationalReportType.debtAging =>
        _debtAgingPresentation(normalized),
      OperationalReportType.expenses => EnumPresentation(
          label: normalized,
          tone: SemanticTone.neutral,
          icon: Icons.receipt_long_outlined,
        ),
      _ => EnumPresentation.unknown(rawValue: normalized),
    };

    return presentation.isKnown
        ? presentation
        : EnumPresentation.unknown(rawValue: normalized);
  }

  EnumPresentation _debtAgingPresentation(String value) {
    final bucket = ReceivableAgingBucket.fromWire(value);
    if (bucket.isKnown) {
      return EnumPresentationRegistry.resolveReceivableAgingBucket(bucket);
    }
    final paymentStatus = InvoicePaymentStatus.fromWire(value);
    final presentation =
        EnumPresentationRegistry.resolveInvoicePaymentStatus(paymentStatus);
    return presentation.isKnown
        ? presentation
        : EnumPresentation.unknown(rawValue: value);
  }

  String _date(String key) => _dateFirst([key]);

  String _dateFirst(List<String> keys) {
    for (final key in keys) {
      final raw = record.valueAt(key);
      if (raw == null) continue;
      final parsed = DateTime.tryParse(raw.toString());
      return parsed == null ? raw.toString() : DateFormatter.date(parsed);
    }
    return '—';
  }

  String _saleTypeLabel(String value) {
    final presentation = EnumPresentationRegistry.resolveSaleType(
      SaleType.fromWire(value),
    );
    return presentation.isKnown ? presentation.label : value;
  }

  String _amount(String key) {
    final raw = record.valueAt(key);
    if (raw == null) return '—';
    final rowCurrency = record.textAt('currency_code', fallback: '');
    final effectiveCurrency = rowCurrency.isEmpty ? currencyCode : rowCurrency;
    final formatted = AmountFormatter.format(raw.toString());
    return effectiveCurrency.isEmpty
        ? formatted
        : '$formatted $effectiveCurrency';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final descriptor = switch (type) {
      OperationalReportType.sales => (
        reference: _first(['invoice_uuid', 'invoice_id']),
        party: _first(['pos_name', 'created_by_name']),
        date: _date('invoice_date'),
        amount: _amount('invoice_total_amount'),
        status: _first(['payment_status']),
        detail: 'المسدّد: ' +
            _amount('paid_amount') +
            '  •  المتبقي: ' +
            _amount('remaining_amount'),
      ),
      OperationalReportType.expenses => (
        reference: _first(['expense_uuid', 'expense_id']),
        party: _first(['created_by_name'], fallback: 'مصروف الشبكة'),
        date: _date('expense_date'),
        amount: _amount('expense_total_amount'),
        status: 'مصروف تشغيلي',
        detail: _first(['items'], fallback: 'سند مصروف الشبكة'),
      ),
      OperationalReportType.networkWallet => (
        reference: _first(['log_id']),
        party: _first(['wallet_uuid', 'log_statement']),
        date: _date('log_date'),
        amount: _amount('log_amount'),
        status: _first(['log_operation']),
        detail: _first(['created_by_name'], fallback: 'حركة محفظة الشبكة'),
      ),
      OperationalReportType.posWallet => (
        reference: _first(['log_id']),
        party: _first(['pos_name', 'wallet_uuid', 'log_statement']),
        date: _date('log_date'),
        amount: _amount('log_amount'),
        status: _first(['log_operation_type']),
        detail: _first(['log_statement'], fallback: 'حركة محفظة نقطة البيع'),
      ),
      OperationalReportType.repayments => (
        reference: _first(['repayment_uuid', 'repayment_id']),
        party: _first(['pos_name', 'pos_id', 'created_by_name']),
        date: _date('repayment_date'),
        amount: _amount('amount'),
        status: _first(['status']),
        detail: _first(['payment_method', 'reference_number', 'reversal_reason']),
      ),
      OperationalReportType.debtAging => (
        reference: _first(['invoice_uuid', 'invoice_id']),
        party: _first(['pos_name', 'pos_id']),
        date: _date('invoice_date'),
        amount: _amount('remaining_amount'),
        status: _first(['aging_bucket', 'payment_status']),
        detail: 'إجمالي الفاتورة: ' +
            _amount('invoice_total_amount') +
            '  •  عمر الدين: ' +
            _first(['age_days']) +
            ' يوم',
      ),
      OperationalReportType.requests => (
        reference: _first(['request_uuid', 'request_id']),
        party: _first(['pos_name', 'pos_id']),
        date: _date('request_date'),
        amount: _amount('request_total_amount'),
        status: _first(['status']),
        detail: _saleTypeLabel(_first(['sale_type'])),
      ),
      _ => (
        reference: _first(['reference', 'uuid', 'id', 'log_id']),
        party: _first(['name', 'pos_name', 'network_name', 'created_by_name']),
        date: _dateFirst([
          'date',
          'created_at',
          'log_date',
          'invoice_date',
          'request_date',
        ]),
        amount: _amount('amount'),
        status: _first([
          'status',
          'payment_status',
          'log_operation',
          'log_operation_type',
        ]),
        detail: _first(['description', 'statement', 'log_statement']),
      ),
    };

    final statusPresentation = _statusPresentation(descriptor.status);

    return CustomSurfaceCard(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      backgroundColor: colors.surfaceContainerLow,
      borderColor: colors.outlineVariant.withValues(alpha: 0.65),
      radius: 18,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    descriptor.reference,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CustomStatusBadge(
                  label: statusPresentation.label,
                  tone: statusPresentation.tone,
                  isCompact: true,
                ),
              ],
            ),
            AppSpacing.vSm,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        descriptor.party,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descriptor.date,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      descriptor.amount,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      descriptor.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
    );
  }
}
