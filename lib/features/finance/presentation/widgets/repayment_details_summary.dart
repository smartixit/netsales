import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/features/finance/domain/entities/repayment_payment_method.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

class RepaymentDetailsSummary extends StatelessWidget {
  const RepaymentDetailsSummary({
    super.key,
    required this.repayment,
    required this.isNetworkView,
  });

  final PosRepaymentEntity repayment;
  final bool isNetworkView;

  IconData get _paymentIcon => switch (repayment.typedPaymentMethod) {
    RepaymentPaymentMethod.cash => Icons.payments_outlined,
    RepaymentPaymentMethod.bank => Icons.account_balance_outlined,
    RepaymentPaymentMethod.wallet =>
      Icons.account_balance_wallet_outlined,
    RepaymentPaymentMethod.unknown => Icons.help_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusLabel = repayment.isCompleted
        ? 'سداد مكتمل'
        : repayment.isReversed
            ? 'سند معكوس'
            : 'حالة غير معروفة';
    final statusTone = repayment.isCompleted
        ? SemanticTone.success
        : repayment.isReversed
            ? SemanticTone.danger
            : SemanticTone.neutral;

    final primaryPartyLabel = isNetworkView ? 'نقطة البيع' : 'الشبكة';
    final primaryPartyName = isNetworkView
        ? (repayment.posName ?? 'نقطة بيع #${repayment.posId}')
        : (repayment.networkName ?? 'شبكة #${repayment.networkId}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.35),
            borderRadius: AppRadius.xlRadius,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'إجمالي سند السداد',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CustomStatusBadge(label: statusLabel, tone: statusTone),
                ],
              ),
              AppSpacing.vSm,
              Text(
                AmountFormatter.format(repayment.amount.toString()),
                style: AppTypography.displaySmall.copyWith(
                  color: colors.primary,
                ),
              ),
              AppSpacing.vMd,
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  CustomChip(
                    label: repayment.typedPaymentMethod.label,
                    icon: _paymentIcon,
                  ),
                  CustomChip(
                    label: 'سند #${repayment.repaymentId}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  if (repayment.repaymentDate != null)
                    CustomChip(
                      label: _dateLabel(repayment.repaymentDate!),
                      icon: Icons.calendar_today_outlined,
                    ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vMd,
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بيانات العملية',
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                ),
              ),
              AppSpacing.vMd,
              _MetadataRow(label: primaryPartyLabel, value: primaryPartyName),
              _MetadataRow(
                label: isNetworkView ? 'الشبكة' : 'نقطة البيع',
                value: isNetworkView
                    ? (repayment.networkName ?? 'شبكة #${repayment.networkId}')
                    : (repayment.posName ?? 'نقطة بيع #${repayment.posId}'),
              ),
              if (repayment.referenceNumber?.trim().isNotEmpty ?? false)
                _MetadataRow(
                  label: 'رقم المرجع',
                  value: repayment.referenceNumber!.trim(),
                ),
              if (repayment.repaymentUuid?.isNotEmpty ?? false)
                _MetadataRow(
                  label: 'معرّف السند',
                  value: repayment.repaymentUuid!,
                ),
              if (repayment.notes?.trim().isNotEmpty ?? false)
                _MetadataRow(
                  label: 'الملاحظات',
                  value: repayment.notes!.trim(),
                ),
              if (repayment.isReversed) ...[
                if (repayment.reversedAt != null)
                  _MetadataRow(
                    label: 'تاريخ العكس',
                    value: _dateLabel(repayment.reversedAt!),
                  ),
                if (repayment.reversalReason?.trim().isNotEmpty ?? false)
                  _MetadataRow(
                    label: 'سبب العكس',
                    value: repayment.reversalReason!.trim(),
                  ),
                if (repayment.reversalRepaymentId != null)
                  _MetadataRow(
                    label: 'سند العكس المرتبط',
                    value: '#${repayment.reversalRepaymentId}',
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _dateLabel(String value) {
    if (value.length <= 10) return value;
    return value.substring(0, 10);
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacing.giant + AppSpacing.lg,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
