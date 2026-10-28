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
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة السند المالي الرقمي الهيرو للفاتورة (InvoiceHeroBondCard)
/// ============================================================================
/// تعرض الهيدر المالي الرئيسي للفاتورة بنمط السند الرقمي المؤسسي الفاخر:
/// هوية نقطة البيع، المبلغ الإجمالي، مؤشر النبض والتسوية المالية، شريط الهوية السيادي،
/// وفاصل التخريم الرقمي، والـ UUID القابل للنسخ اللحظي.
class InvoiceHeroBondCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoiceHeroBondCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPaid = invoice.isFullyPaid;
    final isCash = invoice.isCash;

    // اللون المحوري للحركة المالية (نقدي زمردي / آجل كهرماني)
    final themeColor = isCash ? colors.primary : colors.warning;
    final statusColor = isPaid ? colors.primary : colors.warning;

    final formattedTotal = AmountFormatter.formatValue(invoice.invoiceTotalAmount);
    final formattedPaid = AmountFormatter.formatValue(invoice.paidAmount);
    final formattedRemaining = AmountFormatter.formatValue(invoice.remainingAmount);

    final totalAmount = invoice.invoiceTotalAmount > 0 ? invoice.invoiceTotalAmount : 1.0;
    final paidRatio = (invoice.paidAmount / totalAmount).clamp(0.0, 1.0);

    final dt = DateFormatter.tryParse(invoice.invoiceDate ?? invoice.createdAt ?? '');
    final dateStr = dt != null ? DateFormatter.dateTime(dt) : (invoice.invoiceDate ?? '');

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
                    themeColor.withValues(alpha: 0.06),
                    colors.surface.withValues(alpha: 0.4),
                    colors.surfaceContainerLowest,
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 1. ترويسة هوية نقطة البيع وحالة السداد ──
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
                        // أيقونة نقطة البيع بوعاء سكويركل
                        Container(
                          width: 42.r,
                          height: 42.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeColor.withValues(alpha: 0.18),
                                themeColor.withValues(alpha: 0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.28),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: themeColor,
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
                                invoice.posName ?? 'نقطة بيع #${invoice.posId}',
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
                                invoice.networkName ?? 'شبكة #${invoice.networkId}',
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
                        // شارة حالة السداد ونوع البيع
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
                                    invoice.paymentStatusLabel,
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
                              isCash ? 'بيع نقدي' : 'بيع آجل',
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

                  // ── 2. المبلغ المالي الإجمالي المحوري ──
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
                          'إجمالي الفاتورة المعتمدة',
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
                                  color: themeColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // مؤشر مسار التسوية المالية (سداد كامل أو متبقي آجل)
                        AppSpacing.vSm,
                        if (!isPaid && invoice.remainingAmount > 0) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: SizedBox(
                              height: 6.h,
                              child: Row(
                                children: [
                                  if (paidRatio > 0)
                                    Expanded(
                                      flex: (paidRatio * 100).round(),
                                      child: Container(color: colors.primary),
                                    ),
                                  Expanded(
                                    flex: ((1.0 - paidRatio) * 100).round(),
                                    child: Container(
                                      color: colors.warning.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.vXxs,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مسدد: $formattedPaid ر.ي',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                              Text(
                                'متبقي: $formattedRemaining ر.ي',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.warning,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 13.r,
                                color: colors.primary,
                              ),
                              AppSpacing.hXxs,
                              Text(
                                'تم سداد ومطابقة كامل المبلغ بنجاح',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── 3. فاصل التخريم الرقمي السيادي (Perforated Tear Line) ──
                  _SovereignTearLine(
                    edgeColor: colors.surface,
                    dividerColor: colors.outlineVariant.withValues(alpha: 0.35),
                  ),

                  // ── 4. التذييل التعريفي: رمز السند وتاريخ المعاملة ──
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: 16.w,
                      end: 14.w,
                      top: 10.h,
                      bottom: 10.h,
                    ),
                    child: Row(
                      children: [
                        // كبسولة الـ UUID مع ميزة النقر للنسخ الفوري
                        Expanded(
                          child: CustomInteractiveBounce(
                            onTap: () {
                              UrlLauncherService.copyToClipboard(invoice.invoiceUuid);
                              CustomSnackbar.show(
                                title: 'تم نسخ رمز السند',
                                message: 'تم نسخ معرّف الفاتورة إلى الحافظة بنجاح',
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
                                    color: themeColor,
                                  ),
                                  AppSpacing.hXs,
                                  Expanded(
                                    child: Text(
                                      '#${invoice.invoiceUuid}',
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

            // شريط الهوية السيادي الجانبي
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 4.w, color: themeColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// ودجت فاصل بتأثير قصاصة وتخريم السند المالي الرسمي
class _SovereignTearLine extends StatelessWidget {
  final Color edgeColor;
  final Color dividerColor;

  const _SovereignTearLine({
    required this.edgeColor,
    required this.dividerColor,
  });

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
