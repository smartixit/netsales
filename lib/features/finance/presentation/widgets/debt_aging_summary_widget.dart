import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/debt_summary_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class DebtAgingSummaryWidget extends StatelessWidget {
  final DebtSummaryEntity summary;
  final String? selectedBucket;
  final ValueChanged<String?> onBucketSelected;

  const DebtAgingSummaryWidget({
    super.key,
    required this.summary,
    required this.selectedBucket,
    required this.onBucketSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إجمالي الذمم والديون المستحقة',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXs,
                  Text(
                    AmountFormatter.format(summary.totalReceivables.toString()),
                    style: AppTypography.titleLarge.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${summary.totalOutstandingInvoices} فاتورة آجلة',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${summary.unpaidInvoicesCount} غير مسددة · '
                      '${summary.partiallyPaidInvoicesCount} مسددة جزئياً',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          Text(
            'تحليل الشرائح العمرية للمديونية (سداد FIFO):',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vSm,
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _DebtAgingBucketChip(
                  label: 'الكل',
                  bucketKey: null,
                  amount: summary.totalReceivables,
                  isSelected: selectedBucket == null,
                  onSelected: onBucketSelected,
                ),
                AppSpacing.hSm,
                _DebtAgingBucketChip(
                  label: '1-30 يوم',
                  bucketKey: '0_30',
                  amount: summary.agingBuckets['0_30'] ?? 0.0,
                  isSelected: selectedBucket == '0_30',
                  onSelected: onBucketSelected,
                ),
                AppSpacing.hSm,
                _DebtAgingBucketChip(
                  label: '31-60 يوم',
                  bucketKey: '31_60',
                  amount: summary.agingBuckets['31_60'] ?? 0.0,
                  isSelected: selectedBucket == '31_60',
                  onSelected: onBucketSelected,
                ),
                AppSpacing.hSm,
                _DebtAgingBucketChip(
                  label: '61-90 يوم',
                  bucketKey: '61_90',
                  amount: summary.agingBuckets['61_90'] ?? 0.0,
                  isSelected: selectedBucket == '61_90',
                  onSelected: onBucketSelected,
                ),
                AppSpacing.hSm,
                _DebtAgingBucketChip(
                  label: '> 90 يوم (حرجة)',
                  bucketKey: 'over_90',
                  amount: summary.agingBuckets['over_90'] ?? 0.0,
                  isSelected: selectedBucket == 'over_90',
                  onSelected: onBucketSelected,
                  isCritical: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtAgingBucketChip extends StatelessWidget {
  const _DebtAgingBucketChip({
    required this.label,
    required this.bucketKey,
    required this.amount,
    required this.isSelected,
    required this.onSelected,
    this.isCritical = false,
  });

  final String label;
  final String? bucketKey;
  final double amount;
  final bool isSelected;
  final ValueChanged<String?> onSelected;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: () => onSelected(bucketKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isCritical ? colors.error : colors.primary)
              : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? (isCritical ? colors.error : colors.primary)
                : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            AppSpacing.vXs,
            Text(
              AmountFormatter.format(amount.toString()),
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: isSelected
                    ? colors.onPrimary
                    : (isCritical && amount > 0
                          ? colors.error
                          : colors.onSurface),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
