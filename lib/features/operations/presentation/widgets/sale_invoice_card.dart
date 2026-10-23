import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/widgets/animations/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة فاتورة المبيعات التفاعلية (SaleInvoiceCard)
/// ============================================================================
/// تعرض تفاصيل الفاتورة، حالة السداد، نوع البيع (نقدي/آجل)، والمبالغ المالية بدقة.
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
    final formattedRemaining = AmountFormatter.formatValue(invoice.remainingAmount);

    return CustomInteractiveBounce(
      onTap: onTap ?? () {},
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: AppElevation.level1(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. الترويسة: اسم نقطة البيع وشارة نوع البيع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: colors.primary,
                          size: 18.r,
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
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (invoice.invoiceDate != null) ...[
                              AppSpacing.vXxs,
                              Text(
                                invoice.invoiceDate!,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.hSm,
                // شارة نوع البيع (نقدي / آجل)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isCash
                        ? colors.success.withValues(alpha: 0.1)
                        : colors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    invoice.saleTypeLabel.isNotEmpty
                        ? invoice.saleTypeLabel
                        : (isCash ? 'نقدي' : 'آجل'),
                    style: AppTypography.labelSmall.copyWith(
                      color: isCash ? colors.success : colors.warning,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),

            AppSpacing.vMd,

            // 2. الجزء الأوسط: المبالغ المالية وعدد الكروت
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ الإجمالي',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
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
                            style: AppTypography.titleLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.hXs,
                          Text(
                            'ر.ي',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // حالة السداد والمتبقي إن وجد
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isFullyPaid
                            ? colors.primary.withValues(alpha: 0.08)
                            : colors.error.withValues(alpha: 0.08),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: Text(
                        isFullyPaid
                            ? 'مسددة بالكامل'
                            : 'متبقي: $formattedRemaining ر.ي',
                        style: AppTypography.labelSmall.copyWith(
                          color: isFullyPaid ? colors.primary : colors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                    if (invoice.totalCardsCount > 0) ...[
                      AppSpacing.vXxs,
                      Text(
                        '${invoice.totalCardsCount} كرت إجمالي',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
