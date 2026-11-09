import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_repayment_entity.dart';
import 'package:netsales/core/enums/repayment_payment_method.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
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

  IconData _paymentIcon() => switch (repayment.typedPaymentMethod) {
    RepaymentPaymentMethod.cash => Icons.payments_outlined,
    RepaymentPaymentMethod.bank => Icons.account_balance_outlined,
    RepaymentPaymentMethod.wallet => Icons.account_balance_wallet_outlined,
    RepaymentPaymentMethod.unknown => Icons.help_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final partyLabel = isNetworkView ? 'نقطة البيع' : 'الشبكة';
    final partyName = isNetworkView
        ? (repayment.posName ?? 'نقطة بيع #${repayment.posId}')
        : (repayment.networkName ?? 'شبكة #${repayment.networkId}');
    final statusLabel = repayment.isCompleted
        ? 'مكتمل'
        : repayment.isReversed
        ? 'معكوس'
        : 'غير معروف';
    final statusTone = repayment.isCompleted
        ? SemanticTone.success
        : repayment.isReversed
        ? SemanticTone.danger
        : SemanticTone.neutral;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.level1(context),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xxxl,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: colors.onPrimaryContainer,
                    size: AppSpacing.xl,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سند سداد #${repayment.repaymentId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      if (repayment.repaymentDate != null)
                        Text(
                          _dateLabel(repayment.repaymentDate!),
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                AppSpacing.hXs,
                CustomStatusBadge(label: statusLabel, tone: statusTone),
              ],
            ),
            AppSpacing.vMd,
            Row(
              children: [
                Text(
                  '$partyLabel:',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.hXs,
                Expanded(
                  child: Text(
                    partyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vSm,
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                CustomChip(
                  label: repayment.typedPaymentMethod.label,
                  icon: _paymentIcon(),
                  isCompact: true,
                ),
                CustomChip(
                  label: '${repayment.allocations.length} فاتورة',
                  icon: Icons.account_balance_outlined,
                  isCompact: true,
                ),
              ],
            ),
            AppSpacing.vSm,
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مبلغ سند السداد',
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          AmountFormatter.format(repayment.amount.toString()),
                          style: AppTypography.titleLarge.copyWith(
                            color: repayment.isReversed
                                ? colors.onSurfaceVariant
                                : colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_rounded,
                    color: colors.onSurfaceVariant,
                    size: AppSpacing.lg,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(String value) {
    if (value.length <= 10) return value;
    return value.substring(0, 10);
  }
}
