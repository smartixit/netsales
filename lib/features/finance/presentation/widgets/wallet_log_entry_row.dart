import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/wallet_operation_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// صف دفتر الأستاذ: اتجاه الحركة مصدره Enum الخادم، لا إشارة قيمة المبلغ.
class WalletLogEntryRow extends StatelessWidget {
  final EnumPresentation operation;
  final WalletOperationType operationType;
  final double amount;
  final String? statement;
  final String? date;
  final int index;

  const WalletLogEntryRow({
    super.key,
    required this.operation,
    required this.operationType,
    required this.amount,
    required this.statement,
    required this.date,
    required this.index,
  });

  String get _amountSign {
    return switch (operationType) {
      WalletOperationType.deposit => '+',
      WalletOperationType.withdraw => '−',
      WalletOperationType.unknown => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final amountColor = switch (operationType) {
      WalletOperationType.deposit => colors.success,
      WalletOperationType.withdraw => colors.error,
      WalletOperationType.unknown => colors.onSurface,
    };

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
          CustomStatusBadge.fromPresentation(operation, isCompact: true),
          AppSpacing.hSm,
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statement?.trim().isNotEmpty == true
                      ? statement!
                      : operation.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (date != null && date!.length >= 10) ...[
                  AppSpacing.vXs,
                  Text(
                    date!.substring(0, 10),
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.hSm,
          Flexible(
            flex: 3,
            child: Text(
              '$_amountSign${AmountFormatter.format(amount.abs().toString())}',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
