import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة طلب توريد الكروت التفاعلية (VoucherRequestCard)
/// ============================================================================
/// تعرض تفاصيل طلب التوريد، حالة الاعتماد، والقيمة الإجمالية،
/// مع رصيف قرار مباشر للاعتماد والرفض لمالك الشبكة والمشرف.
class VoucherRequestCard extends StatelessWidget {
  final VoucherRequestEntity request;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const VoucherRequestCard({
    super.key,
    required this.request,
    this.onTap,
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

    return CustomInteractiveBounce(
      onTap: onTap ?? () {},
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isPending
                ? colors.warning.withValues(alpha: 0.35)
                : colors.outlineVariant.withValues(alpha: 0.28),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الترويسة: اسم نقطة البيع وشارة الحالة
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: isPending
                        ? colors.warning.withValues(alpha: 0.12)
                        : (isApproved
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.surfaceContainerHighest),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: isPending
                          ? colors.warning.withValues(alpha: 0.25)
                          : colors.outlineVariant.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: isPending
                        ? colors.warning
                        : (isApproved ? colors.primary : colors.onSurfaceVariant),
                    size: 19.r,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.posName ?? 'نقطة بيع #${request.posId}',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Text(
                        request.networkName != null
                            ? '${request.networkName} • ${request.requestDate ?? ''}'
                            : (request.requestDate ?? ''),
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                // شارة حالة الطلب
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? colors.warning.withValues(alpha: 0.12)
                        : (isApproved
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.error.withValues(alpha: 0.1)),
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(
                      color: isPending
                          ? colors.warning.withValues(alpha: 0.3)
                          : (isApproved
                              ? colors.primary.withValues(alpha: 0.25)
                              : colors.error.withValues(alpha: 0.25)),
                      width: 0.8.w,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isPending) ...[
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: colors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hXxs,
                      ],
                      Text(
                        request.statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: isPending
                              ? colors.warning
                              : (isApproved
                                  ? colors.primary
                                  : (isRejected ? colors.error : colors.onSurfaceVariant)),
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // 2. المحتوى المالي والكمي للطلب
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: AppRadius.mdRadius,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قيمة التوريد المطلوب',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        AppSpacing.vXxs,
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formattedTotal,
                                style: AppTypography.titleMedium.copyWith(
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hSm,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: AppRadius.fullRadius,
                    ),
                    child: Text(
                      '${request.totalCardsCount} كرت مطلوب',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (request.requestNote != null && request.requestNote!.isNotEmpty) ...[
              AppSpacing.vXs,
              Text(
                'ملاحظة: ${request.requestNote}',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // 3. رصيف القرار المباشر للطلبات المعلقة
            if (isPending && (onApprove != null || onReject != null)) ...[
              AppSpacing.vSm,
              Row(
                children: [
                  if (onApprove != null)
                    Expanded(
                      flex: 2,
                      child: CustomButton.primary(
                        text: 'اعتماد الطلب',
                        icon: Icons.check_rounded,
                        onPressed: onApprove!,
                      ),
                    ),
                  if (onApprove != null && onReject != null) AppSpacing.hSm,
                  if (onReject != null)
                    Expanded(
                      flex: 1,
                      child: CustomButton.outline(
                        text: 'رفض',
                        icon: Icons.close_rounded,
                        onPressed: onReject!,
                      ),
                    ),
                ],
              ),
            ],

            // 4. التذييل: كود الطلب وسهم الانتقال
            if (!isPending) ...[
              AppSpacing.vSm,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: AppRadius.xsRadius,
                    ),
                    child: Text(
                      request.requestUuid,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11.r,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.35),
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
