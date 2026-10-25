import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة السند الرقمي لطلب التوريد (RequestHeroBondCard)
/// ============================================================================
/// تعرض الهيدر المالي لطلب توريد كروت الشبكة:
/// إجمالي القيمة المطلوبة، حالة الطلب وشاراته، والـ UUID القابل للنسخ.
class RequestHeroBondCard extends StatelessWidget {
  final VoucherRequestEntity request;

  const RequestHeroBondCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = request.isCash;

    final statusColor = request.isPending
        ? colors.warning
        : request.isApproved
            ? colors.success
            : request.isRejected
                ? colors.error
                : colors.onSurfaceVariant;

    final statusBg = statusColor.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: AppElevation.level2(context),
      ),
      child: Column(
        children: [
          // ── 1. الرأس العلوي مع شارة الحالة ونوع الشراء ──
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // شارة حالة الطلب
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        request.isPending
                            ? Icons.hourglass_top_rounded
                            : request.isApproved
                                ? Icons.check_circle_rounded
                                : request.isRejected
                                    ? Icons.cancel_rounded
                                    : Icons.block_rounded,
                        size: 14.r,
                        color: statusColor,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        request.statusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // شارة نوع الشراء (نقدي / آجل)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isCash
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.secondary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    request.saleTypeLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: isCash ? colors.primary : colors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. إجمالي قيمة الطلب التقديرية ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'إجمالي قيمة طلب التوريد',
                  style: AppTypography.labelMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                AppSpacing.vXxs,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      AmountFormatter.formatValue(request.requestTotalAmount),
                      style: AppTypography.currencyHero.copyWith(
                        color: colors.onSurface,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      'ر.ي',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.vMd,

          // ── 3. خط الفاصل المشرشر ──
          _ReceiptDivider(lineColor: colors.outlineVariant.withValues(alpha: 0.5)),

          // ── 4. التذييل: رمز الـ UUID وتاريخ الطلب ──
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              children: [
                // كبسولة الـ UUID مع النقر للنسخ
                Expanded(
                  child: CustomInteractiveBounce(
                    onTap: () {
                      UrlLauncherService.copyToClipboard(request.requestUuid);
                      CustomSnackbar.show(
                        title: 'تم النسخ',
                        message: 'تم نسخ رمز طلب التوريد إلى الحافظة',
                        type: SnackType.info,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.smRadius,
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 14.r,
                            color: colors.primary,
                          ),
                          AppSpacing.hXs,
                          Expanded(
                            child: Text(
                              request.requestUuid,
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurface,
                                fontFamily: 'monospace',
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (request.requestDate != null || request.createdAt != null) ...[
                  AppSpacing.hSm,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13.r,
                        color: colors.onSurfaceVariant,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        request.requestDate ?? request.createdAt!,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDivider extends StatelessWidget {
  final Color lineColor;

  const _ReceiptDivider({required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();

        return SizedBox(
          width: boxWidth,
          height: 1.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: lineColor),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
