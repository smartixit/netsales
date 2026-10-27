import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// عنصر صف طلب التوريد في السجل المالي (VoucherRequestLedgerTile)
/// ============================================================================
/// يعرض طلب التوريد داخل السجل المتصل مع إبراز حالة المراجعة المباشرة.
class VoucherRequestLedgerTile extends StatelessWidget {
  final VoucherRequestEntity request;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const VoucherRequestLedgerTile({
    super.key,
    required this.request,
    required this.onTap,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPending = request.isPending;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;
    final formattedTotal = AmountFormatter.formatValue(request.requestTotalAmount);

    final dt = request.requestDate != null
        ? DateTime.tryParse(request.requestDate!)
        : (request.createdAt != null ? DateTime.tryParse(request.createdAt!) : null);
    final timeStr = dt != null ? DateFormatter.time(dt) : '';

    final statusColor = isPending
        ? colors.warning
        : (isApproved
            ? colors.primary
            : (isRejected ? colors.error : colors.onSurfaceVariant));

    final subtitleParts = [
      request.requestUuid,
      if (timeStr.isNotEmpty) timeStr,
      if (request.totalCardsCount > 0) '${request.totalCardsCount} كرت',
    ].join(' • ');

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12.h,
        ),
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              children: [
                // 1. أيقونة التوريد بهالة لونية ناعمة
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isPending
                        ? Icons.hourglass_top_rounded
                        : (isApproved
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined),
                    color: statusColor,
                    size: 19.r,
                  ),
                ),

                AppSpacing.hSm,

                // 2. الهوية والمعلومات
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.posName ?? 'نقطة بيع #${request.posId}',
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSpacing.hXs,
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: (request.isCash ? colors.primary : colors.tertiary)
                                  .withValues(alpha: 0.1),
                              borderRadius: AppRadius.fullRadius,
                            ),
                            child: Text(
                              request.isCash ? 'نقدي' : 'آجل',
                              style: AppTypography.labelSmall.copyWith(
                                color: request.isCash
                                    ? colors.primary
                                    : colors.tertiary,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXxs,
                      Text(
                        subtitleParts,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                          fontSize: 9.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                AppSpacing.hSm,

                // 3. الجزء المالي والحالة
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 100.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedTotal,
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            AppSpacing.hXxs,
                            Text(
                              'ر.ي',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.vXxs,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          request.statusLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 4. أزرار القرار السريع للطلبات المعلقة
            if (isPending && (onApprove != null || onReject != null)) ...[
              AppSpacing.vSm,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null) ...[
                    CustomButton.text(
                      text: 'رفض',
                      size: AppButtonSize.small,
                      foregroundColor: colors.error,
                      onPressed: onReject!,
                    ),
                    AppSpacing.hSm,
                  ],
                  if (onApprove != null)
                    CustomButton.primary(
                      text: 'اعتماد الطلب',
                      size: AppButtonSize.small,
                      icon: Icons.check_rounded,
                      onPressed: onApprove!,
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
