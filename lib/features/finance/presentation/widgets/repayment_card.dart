import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class RepaymentCard extends StatelessWidget {
  final PosRepaymentEntity repayment;
  final VoidCallback onTap;
  final bool isNetworkView;

  const RepaymentCard({
    super.key,
    required this.repayment,
    required this.onTap,
    this.isNetworkView = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final partyLabel = isNetworkView ? 'نقطة البيع:' : 'المزود (الشبكة):';
    final partyName = isNetworkView
        ? (repayment.posName ?? 'نقطة بيع #${repayment.posId}')
        : (repayment.networkName ?? 'شبكة #${repayment.networkId}');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppElevation.level1(context),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    AppSpacing.hSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سند سداد #${repayment.repaymentId}',
                          style: AppTypography.titleMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (repayment.repaymentDate != null)
                          Text(
                            repayment.repaymentDate!.substring(0, 10),
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                CustomStatusBadge(
                  label: repayment.isCompleted ? 'مسدد وموزع' : 'معكوس / ملغي',
                  tone: repayment.isCompleted
                      ? SemanticTone.success
                      : SemanticTone.danger,
                ),
              ],
            ),
            AppSpacing.vSm,
            Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            AppSpacing.vXs,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  partyLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  partyName,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مبلغ السند المحصل',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        AmountFormatter.format(repayment.amount.toString()),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${repayment.allocations.length} فواتير مسواة (FIFO)',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
