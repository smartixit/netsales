import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

class OperationalReportRecordCard extends StatelessWidget {
  const OperationalReportRecordCard({
    required this.record,
    required this.type,
    super.key,
  });

  final OperationalReportRecord record;
  final OperationalReportType type;

  String _first(List<String> keys, {String fallback = '—'}) {
    for (final key in keys) {
      final value = record.textAt(key, fallback: '');
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  SemanticTone _statusTone(String value) {
    final status = value.toUpperCase();
    if (status == 'PAID' ||
        status == 'DEPOSIT' ||
        status == 'COMPLETED' ||
        status == 'APPROVED') {
      return SemanticTone.success;
    }
    if (status == 'PARTIALLY_PAID' || status == 'PENDING' || status == 'WITHDRAW') {
      return SemanticTone.warning;
    }
    if (status == 'REJECTED' || status == 'REVERSED' || status == 'UNPAID') {
      return SemanticTone.danger;
    }
    return SemanticTone.neutral;
  }

  String _amount(String key) {
    final raw = record.valueAt(key);
    if (raw == null) return '—';
    return AmountFormatter.format(raw.toString());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final descriptor = switch (type) {
      OperationalReportType.sales => (
        reference: _first(['invoice_uuid', 'invoice_id']),
        party: _first(['pos.pos_name', 'created_by.name']),
        date: _first(['invoice_date']),
        amount: _amount('invoice_total_amount'),
        status: _first(['payment_status']),
        detail: 'المسدّد: ' + _amount('paid_amount') + '  •  المتبقي: ' + _amount('remaining_amount'),
      ),
      OperationalReportType.expenses => (
        reference: _first(['expense_uuid', 'expense_id']),
        party: _first(['created_by_user.name', 'created_by.name', 'network.network_name']),
        date: _first(['expense_date']),
        amount: _amount('expense_total_amount'),
        status: 'مصروف تشغيلي',
        detail: _first(['items.0.item_statement'], fallback: 'سند مصروف الشبكة'),
      ),
      OperationalReportType.networkWallet => (
        reference: _first(['log_id']),
        party: _first(['log_statement']),
        date: _first(['log_date']),
        amount: _amount('log_amount'),
        status: _first(['log_operation']),
        detail: _first(['created_by.name']),
      ),
      OperationalReportType.posWallet => (
        reference: _first(['log_id']),
        party: _first(['log_statement']),
        date: _first(['log_date']),
        amount: _amount('log_amount'),
        status: _first(['log_operation_type']),
        detail: _first(['created_by.name']),
      ),
      OperationalReportType.repayments => (
        reference: _first(['repayment_uuid', 'repayment_id']),
        party: _first(['pos.pos_name']),
        date: _first(['repayment_date']),
        amount: _amount('amount'),
        status: _first(['status']),
        detail: _first(['payment_method', 'reference_number', 'notes']),
      ),
      OperationalReportType.debtAging => (
        reference: _first(['invoice_uuid', 'invoice_id']),
        party: _first(['pos.pos_name']),
        date: _first(['invoice_date']),
        amount: _amount('remaining_amount'),
        status: _first(['aging_bucket', 'payment_status']),
        detail: 'إجمالي الفاتورة: ' + _amount('invoice_total_amount') + '  •  عمر الدين: ' + _first(['age_days']) + ' يوم',
      ),
      OperationalReportType.requests => (
        reference: _first(['request_uuid', 'request_id']),
        party: _first(['pos.pos_name']),
        date: _first(['request_date']),
        amount: _amount('request_total_amount'),
        status: _first(['status']),
        detail: _first(['sale_type']),
      ),
    };

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
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
                CustomStatusBadge(label: descriptor.status, tone: _statusTone(descriptor.status), isCompact: true),
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
      ),
    );
  }
}
