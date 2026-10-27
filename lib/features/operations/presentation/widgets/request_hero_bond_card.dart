import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة السند الرقمي الهيرو لطلب التوريد (RequestHeroBondCard)
/// ============================================================================
/// تعرض الهيدر المالي لطلب توريد كروت الشبكة بنمط السند الرقمي المؤسسي الفاخر:
/// إجمالي القيمة المطلوبة، شارات الحالة، شريط الهوية السيادي، وتفاصيل الـ UUID القابلة للنسخ.
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
    final isPending = request.isPending;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;

    final statusColor = isPending
        ? colors.warning
        : (isApproved
            ? colors.primary
            : (isRejected ? colors.error : colors.onSurfaceVariant));

    final formattedTotal = AmountFormatter.formatValue(request.requestTotalAmount);

    final dt = request.createdAt != null ? DateTime.tryParse(request.createdAt!) : null;
    final dateStr = dt != null ? DateFormatter.dateTime(dt) : (request.createdAt ?? '');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgRadius,
        child: Stack(
          children: [
            // وعاء السند الأساسي مع التوهج المحيطي الناعم
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    statusColor.withValues(alpha: 0.06),
                    colors.surface.withValues(alpha: 0.4),
                    colors.surfaceContainerLowest,
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. ترويسة هوية نقطة البيع وشارة الحالة ──
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      end: 14.w,
                      top: 14.h,
                      bottom: 10.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة حالة التوريد سكويركل
                        Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor.withValues(alpha: 0.18),
                                statusColor.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.28),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isPending
                                ? Icons.hourglass_top_rounded
                                : (isApproved
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.cancel_outlined),
                            color: statusColor,
                            size: 22.r,
                          ),
                        ),
                        AppSpacing.hSm,
                        // اسم نقطة البيع والشبكة
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.posName ?? 'نقطة بيع #${request.posId}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vXxs,
                              Text(
                                request.networkName ?? 'شبكة #${request.networkId}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.5.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hXs,
                        // شارة حالة الطلب
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: AppRadius.fullRadius,
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.28),
                                  width: 0.8.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  AppSpacing.hXxs,
                                  Text(
                                    request.statusLabel,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              isCash ? 'دفع نقدي مطلوب' : 'دفع آجل مطلوب',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── 2. إجمالي القيمة التقديرية للطلب ──
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      end: 16.w,
                      top: 4.h,
                      bottom: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي القيمة التقديرية للطلب',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
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
                                style: AppTypography.currencyHero.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              AppSpacing.hXs,
                              Text(
                                'ر.ي',
                                style: AppTypography.titleMedium.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.vXxs,
                        Text(
                          '${request.totalCardsCount} كرت مطلوب عبر ${request.items.length} باقات',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 3. فاصل التخريم الرقمي السيادي ──
                  _SovereignTearLine(
                    dividerColor: colors.outlineVariant.withValues(alpha: 0.35),
                  ),

                  // ── 4. التذييل التعريفي: رمز الطلب وتاريخ الإرسال ──
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      end: 14.w,
                      top: 10.h,
                      bottom: 10.h,
                    ),
                    child: Row(
                      children: [
                        // كبسولة الـ UUID مع ميزة النقر للنسخ
                        Expanded(
                          child: CustomInteractiveBounce(
                            onTap: () {
                              UrlLauncherService.copyToClipboard(request.requestUuid);
                              CustomSnackbar.show(
                                title: 'تم نسخ رمز السند',
                                message: 'تم نسخ معرّف طلب التوريد إلى الحافظة',
                                type: SnackType.info,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                                borderRadius: AppRadius.smRadius,
                                border: Border.all(
                                  color: colors.outlineVariant.withValues(alpha: 0.3),
                                  width: 0.8.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.copy_rounded,
                                    size: 13.r,
                                    color: statusColor,
                                  ),
                                  AppSpacing.hXs,
                                  Expanded(
                                    child: Text(
                                      '#${request.requestUuid}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.sp,
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

                        if (dateStr.isNotEmpty) ...[
                          AppSpacing.hSm,
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12.r,
                                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                              AppSpacing.hXxs,
                              Text(
                                dateStr,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
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
            ),

            // شريط الحالة السيادي الجانبي
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4.w, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SovereignTearLine extends StatelessWidget {
  final Color dividerColor;

  const _SovereignTearLine({required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
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
                  decoration: BoxDecoration(color: dividerColor),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
