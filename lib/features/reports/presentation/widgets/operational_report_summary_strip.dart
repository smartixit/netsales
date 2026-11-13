import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';

class OperationalReportSummaryStrip extends StatelessWidget {
  const OperationalReportSummaryStrip({
    required this.summary,
    super.key,
  });

  final OperationalReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = summary.metrics;
    final currencyCode = summary.values['currency_code']?.toString() ?? 'YER';
    if (metrics.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: metrics.length,
        separatorBuilder: (_, _) => AppSpacing.hSm,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          final displayValue = metric.isCurrency
              ? CustomInteractiveAmountText(
                  amount: metric.value,
                  currencyCode: currencyCode,
                  trailingText: currencyCode,
                  enableTooltip: true,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.primary,
                    fontWeight: AppTypography.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                )
              : Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
          return Container(
            width: 176,
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                displayValue,
              ],
            ),
          );
        },
      ),
    );
  }
}
