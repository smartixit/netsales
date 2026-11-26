import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/wallet_log_entry.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// عنصر سجل حركة الحساب، مع إظهار أثر الحركة على الرصيد.
class PosWalletLedgerTile extends StatelessWidget {
  const PosWalletLedgerTile({super.key, required this.log, this.onTap});

  final WalletLogEntry log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final operation = log.typedOperationType;
    final presentation = EnumPresentationRegistry.resolveWalletOperationType(
      operation,
      serverLabel: log.operationTypeLabel,
    );
    final isDeposit = log.isDeposit;
    final isWithdraw = log.isWithdraw;
    final amountPrefix = log.amount == 0
        ? ''
        : isDeposit
            ? '+'
            : isWithdraw
                ? '−'
                : '';
    final amountColor = isDeposit
        ? colors.success
        : isWithdraw
            ? colors.error
            : colors.onSurface;
    final amountFormatted = AmountFormatter.format(
      log.amount.toStringAsFixed(2),
    );
    final beforeFormatted = AmountFormatter.format(
      log.balanceBefore.toStringAsFixed(2),
    );
    final afterFormatted = AmountFormatter.format(
      log.balanceAfter.toStringAsFixed(2),
    );

    var dateFormatted = log.logDate ?? log.createdAt ?? '';
    if (dateFormatted.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateFormatted);
        dateFormatted =
            '${DateFormatter.date(parsed)} • ${DateFormatter.time(parsed)}';
      } catch (_) {}
    }

    final toneColor = presentation.tone.color(context);

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.48),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: toneColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    presentation.icon ??
                        Icons.swap_horiz_rounded,
                    size: 19.r,
                    color: toneColor,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.statement.trim().isNotEmpty
                            ? log.statement
                            : presentation.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: AppTypography.semiBold,
                        ),
                      ),
                      if (dateFormatted.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          dateFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$amountPrefix$amountFormatted',
                      maxLines: 1,
                      style: AppTypography.titleMedium.copyWith(
                        color: amountColor,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      log.currencyCode,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرصيد قبل الحركة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          beforeFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرصيد بعد الحركة',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          afterFormatted,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: AppTypography.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (log.createdByName?.trim().isNotEmpty == true) ...[
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      log.createdByName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
