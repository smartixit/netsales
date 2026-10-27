import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة فاتورة المبيعات التفاعلية الفاخرة (SaleInvoiceCard)
/// ============================================================================
/// تعرض فاتورة مبيعات الكروت كهوية سند تجاري سيادي مع إبراز حالة السداد،
/// ونوع البيع (نقدي/آجل)، والمبالغ المالية والمديونية بدقة مانعة للازدحام.
class SaleInvoiceCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;
  final VoidCallback? onTap;

  const SaleInvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = invoice.isCash;
    final isFullyPaid = invoice.isFullyPaid;
    final formattedTotal = AmountFormatter.formatValue(invoice.invoiceTotalAmount);
    final formattedPaid = AmountFormatter.formatValue(invoice.paidAmount);
    final formattedRemaining = AmountFormatter.formatValue(invoice.remainingAmount);

    return CustomInteractiveBounce(
      onTap: onTap ?? () {},
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.w,
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الترويسة: هوية نقطة البيع ونوع البيع (نقدي / آجل)
            Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.storefront_rounded,
                    color: colors.primary,
                    size: 19.r,
                  ),
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.vXxs,
                      Text(
                        invoice.networkName != null
                            ? '${invoice.networkName} • ${invoice.invoiceDate ?? ''}'
                            : (invoice.invoiceDate ?? ''),
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
                // شارة نوع البيع (نقدي زمردي / آجل كهرماني)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCash
                        ? colors.primary.withValues(alpha: 0.1)
                        : colors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullRadius,
                    border: Border.all(
                      color: isCash
                          ? colors.primary.withValues(alpha: 0.25)
                          : colors.warning.withValues(alpha: 0.3),
                      width: 0.8.w,
                    ),
                  ),
                  child: Text(
                    invoice.saleTypeLabel.isNotEmpty
                        ? invoice.saleTypeLabel
                        : (isCash ? 'نقدي' : 'آجل'),
                    style: AppTypography.labelSmall.copyWith(
                      color: isCash ? colors.primary : colors.warning,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vSm,

            // 2. الرصيف المالي الداخلي: إجمالي الفاتورة وحالة السداد
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
                          'قيمة الفاتورة',
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
                  // كبسولة حالة السداد والمديونية
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isFullyPaid
                              ? colors.primary.withValues(alpha: 0.1)
                              : colors.warning.withValues(alpha: 0.12),
                          borderRadius: AppRadius.fullRadius,
                        ),
                        child: Text(
                          isFullyPaid
                              ? 'خالصة السداد'
                              : (invoice.remainingAmount > 0
                                  ? 'متبقي: $formattedRemaining ر.ي'
                                  : 'غير مسددة'),
                          style: AppTypography.labelSmall.copyWith(
                            color: isFullyPaid ? colors.primary : colors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      if (!isFullyPaid && invoice.paidAmount > 0) ...[
                        AppSpacing.vXxs,
                        Text(
                          'مسدد: $formattedPaid ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            AppSpacing.vSm,

            // 3. التذييل التنفيذي: رقم السند الرسمي وتعداد الكروت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
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
                          invoice.invoiceUuid,
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            fontSize: 9.sp,
                          ),
                        ),
                      ),
                      if (invoice.totalCardsCount > 0) ...[
                        AppSpacing.hXs,
                        Text(
                          '•  ${invoice.totalCardsCount} كرت',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ],
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
        ),
      ),
    );
  }
}
