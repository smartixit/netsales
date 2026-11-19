import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

class ProcurementCheckoutSummaryMetric extends StatelessWidget {
  const ProcurementCheckoutSummaryMetric({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.isDiscount = false,
    this.isNet = false,
  });

  final String label;
  final String value;
  final String currency;
  final bool isDiscount;
  final bool isNet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = isNet
        ? colors.primary
        : (isDiscount ? colors.tertiary : colors.onSurface);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isNet
            ? colors.primary.withValues(alpha: .08)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isNet
              ? colors.primary.withValues(alpha: .24)
              : colors.outlineVariant.withValues(alpha: .35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vXxs,
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: AppTypography.titleSmall.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Text(
            currency,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
