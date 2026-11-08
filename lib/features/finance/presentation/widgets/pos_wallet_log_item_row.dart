import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';

class PosWalletLogItemRow extends StatelessWidget {
  final PosWalletLogEntity log;
  final int index;

  const PosWalletLogItemRow({
    super.key,
    required this.log,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDeposit = log.logAmount >= 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: index.isEven
            ? colors.surfaceContainerLowest
            : colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        children: [
          Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isDeposit ? colors.primary : colors.error,
            size: 18,
          ),
          AppSpacing.hSm,
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.logOperationTypeLabel ??
                      log.logOperationType ??
                      'قيد مالي',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (log.logStatement != null)
                  Text(
                    log.logStatement!,
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (log.logDate != null)
            Expanded(
              flex: 2,
              child: Text(
                log.logDate!.substring(0, 10),
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Text(
              AmountFormatter.format(log.logAmount.abs().toString()),
              textAlign: TextAlign.end,
              style: AppTypography.titleSmall.copyWith(
                color: isDeposit ? colors.primary : colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
