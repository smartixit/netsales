import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/services/url_launcher_service.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';
import 'package:netsales/widgets/toasts/custom_snackbar.dart';

/// ============================================================================
/// بطاقة السند المالي الرقمي للفاتورة (InvoiceHeroBondCard)
/// ============================================================================
/// تعرض الهيدر المالي الرئيسي للفاتورة بنمط السند الرقمي المؤسسي:
/// المبلغ الإجمالي، شارة حالة السداد، نوع البيع (نقدي/آجل)، وتفاصيل الـ UUID القابلة للنسخ.
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

    final statusBg = isPaid
        ? colors.success.withValues(alpha: 0.12)
        : colors.warning.withValues(alpha: 0.12);
    final statusColor = isPaid ? colors.success : colors.warning;

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
          // ── 1. الرأس العلوي مع الشارات والنوع ──
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // شارة حالة السداد
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
                        isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                        size: 14.r,
                        color: statusColor,
                      ),
                      AppSpacing.hXxs,
                      Text(
                        invoice.paymentStatusLabel,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // شارة نوع البيع (نقدي / آجل)
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
                    invoice.saleTypeLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: isCash ? colors.primary : colors.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. المبلغ الإجمالي مع رمز العملة ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                Text(
                  'إجمالي الفاتورة الصادرة',
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
                      AmountFormatter.formatValue(invoice.invoiceTotalAmount),
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

          // ── 3. خط الفاصل المشرشر / المنقّط (Perforated Receipt Divider) ──
          _ReceiptDivider(lineColor: colors.outlineVariant.withValues(alpha: 0.5)),

          // ── 4. التذييل التعريفي: رمز الـ UUID وتاريخ الإصدار ──
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
                // كبسولة الـ UUID مع ميزة النقر للنسخ
                Expanded(
                  child: CustomInteractiveBounce(
                    onTap: () {
                      UrlLauncherService.copyToClipboard(invoice.invoiceUuid);
                      CustomSnackbar.show(
                        title: 'تم النسخ',
                        message: 'تم نسخ رمز الفاتورة الرقمي إلى الحافظة',
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
                              invoice.invoiceUuid,
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

                if (invoice.invoiceDate != null || invoice.createdAt != null) ...[
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
                        invoice.invoiceDate ?? invoice.createdAt!,
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

/// ودجت فاصل بتأثير قصاصة السند المالي
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
