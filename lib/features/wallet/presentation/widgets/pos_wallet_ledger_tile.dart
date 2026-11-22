import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_log_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// بطاقة قيد حركة دفتر أستاذ محفظة نقطة البيع (POS Wallet Ledger Tile)
///
/// تستخدم كائن العرض الدلالي الموحد [EnumPresentation] المستخرج عبر [EnumPresentationRegistry].
class PosWalletLedgerTile extends StatelessWidget {
  const PosWalletLedgerTile({super.key, required this.log, this.onTap});

  final PosWalletLogEntity log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final presentation = log.operationPresentation;

    final isDeposit = log.isDeposit;
    final amountFormatted = AmountFormatter.format(
      log.amount.toStringAsFixed(2),
    );
    final beforeFormatted = AmountFormatter.format(
      log.balanceBefore.toStringAsFixed(2),
    );
    final afterFormatted = AmountFormatter.format(
      log.balanceAfter.toStringAsFixed(2),
    );

    final toneColor = presentation.tone.color(context);
    final leadingBg = toneColor.withValues(alpha: 0.12);

    String dateFormatted = log.logDate ?? log.createdAt ?? '';
    if (dateFormatted.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateFormatted);
        dateFormatted =
            '${DateFormatter.date(parsed)} • ${DateFormatter.time(parsed)}';
      } catch (_) {}
    }

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.03),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. أيقونة نوع الحركة المعتمدة دلالياً من السجل المركزي
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: leadingBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: toneColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    presentation.icon ??
                        (isDeposit
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded),
                    size: 18.r,
                    color: toneColor,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),

                // 2. بيان الحركة والوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.statement.isNotEmpty
                                  ? log.statement
                                  : presentation.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: AppTypography.semiBold,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          CustomStatusBadge.fromPresentation(
                            presentation,
                            isCompact: true,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        dateFormatted,
                        maxLines: 1,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.sm),

                // 3. المبلغ المالي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isDeposit ? '+' : '-'}$amountFormatted',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDeposit ? colors.success : colors.onSurface,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      log.currencyCode,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: AppTypography.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // 4. شريط لقطة الرصيد المحاسبي (Balance Snapshot Progression)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 12.r,
                    color: colors.onSurfaceVariant,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'الرصيد: $beforeFormatted',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 11.r,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '$afterFormatted ${log.currencyCode}',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: AppTypography.semiBold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      log.balanceSnapshotSource,
                      style: AppTypography.badgeText.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
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
