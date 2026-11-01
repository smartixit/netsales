import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';

/// ============================================================================
/// بطاقة قيد حركة دفتر الأستاذ (WalletMovementTile)
/// ============================================================================
/// تعرض حركة مالية مقيدة في كشف الحساب بدقة واضحة تشمل الاتجاه، الوصف،
/// التاريخ، والمبلغ مع شارة العملية المحاسبية.
class WalletMovementTile extends StatelessWidget {
  final int logId;
  final String operationLabel;
  final double amount;
  final bool isCredit;
  final String? statement;
  final DateTime? date;
  final String currency;

  const WalletMovementTile({
    super.key,
    required this.logId,
    required this.operationLabel,
    required this.amount,
    required this.isCredit,
    this.statement,
    this.date,
    this.currency = 'ر.ي',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final movementColor = isCredit ? colors.success : colors.error;
    final movementBgColor = isCredit
        ? colors.successContainer.withValues(alpha: 0.35)
        : colors.errorContainer.withValues(alpha: 0.35);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdRadius,
        boxShadow: AppElevation.level1(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 0.8.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. أيقونة اتجاه الحركة (دائن / مدين)
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: movementBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: movementColor,
              size: 20.r,
            ),
          ),

          AppSpacing.hMd,

          // 2. تفاصيل العملية والبيان والتاريخ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        operationLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      '#$logId',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vXs,
                Text(
                  (statement != null && statement!.trim().isNotEmpty)
                      ? statement!.trim()
                      : (isCredit ? 'إضافة / تغذية نقدية' : 'خصم / تسوية حساب'),
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (date != null) ...[
                  AppSpacing.vXs,
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.r,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                      AppSpacing.hXs,
                      Text(
                        DateFormatter.dateTime(date!),
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          AppSpacing.hSm,

          // 3. قيمة الحركة المالية مع الإشارة والعملة
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${AmountFormatter.formatValue(amount)}',
                style: AppTypography.titleSmall.copyWith(
                  color: movementColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                currency,
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
