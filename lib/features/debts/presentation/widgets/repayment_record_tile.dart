import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/debts/domain/entities/repayment_entity.dart';

class RepaymentRecordTile extends StatelessWidget {
  final PosRepaymentEntity repayment;
  final VoidCallback onReverse;
  final VoidCallback onViewReceipt;

  const RepaymentRecordTile({
    super.key,
    required this.repayment,
    required this.onReverse,
    required this.onViewReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isReversed = repayment.isReversed;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isReversed
              ? colors.outlineVariant.withValues(alpha: 0.3)
              : colors.outlineVariant.withValues(alpha: 0.5),
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
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: isReversed
                          ? colors.onSurfaceVariant.withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      isReversed ? Icons.undo_rounded : Icons.check_circle_outline_rounded,
                      color: isReversed ? colors.onSurfaceVariant : const Color(0xFF10B981),
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repayment.repaymentUuid,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isReversed ? colors.onSurfaceVariant : colors.onSurface,
                          decoration: isReversed ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (repayment.posName != null)
                        Text(
                          repayment.posName!,
                          style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AmountFormatter.formatValue(repayment.amount, decimalPlaces: 0)} ر.ي',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isReversed ? colors.onSurfaceVariant : const Color(0xFF10B981),
                      decoration: isReversed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isReversed
                          ? colors.error.withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      isReversed ? 'معكوس' : 'سداد نشط',
                      style: AppTypography.labelSmall.copyWith(
                        color: isReversed ? colors.error : const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طريقة الدفع: ${repayment.paymentMethod}',
                style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
              ),
              Text(
                DateFormatter.format(repayment.repaymentDate, 'yyyy/MM/dd HH:mm'),
                style: AppTypography.labelSmall.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          if (isReversed && repayment.reversalReason != null) ...[
            AppSpacing.vXs,
            Text(
              'سبب العكس: ${repayment.reversalReason}',
              style: AppTypography.labelSmall.copyWith(
                color: colors.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onViewReceipt,
                icon: const Icon(Icons.receipt_rounded, size: 16),
                label: Text('عرض التوزيعات (${repayment.allocations.length})'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
              if (!isReversed)
                OutlinedButton.icon(
                  onPressed: onReverse,
                  icon: Icon(Icons.undo_rounded, size: 14.r, color: colors.error),
                  label: Text('عكس السند', style: TextStyle(color: colors.error)),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
