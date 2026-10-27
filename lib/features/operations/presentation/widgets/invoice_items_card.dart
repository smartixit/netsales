import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';

/// ============================================================================
/// بطاقة بنود كروت الفاتورة السيادية (InvoiceItemsCard)
/// ============================================================================
/// تعرض مصفوفة البنود التفصيلية للباقات المضمنة في الفاتورة مع محاذاة عمودية
/// دقيقة لعمود الصافي والكميات، وأوسمة الخصومات المطبقة.
class InvoiceItemsCard extends StatelessWidget {
  final SaleInvoiceEntity invoice;

  const InvoiceItemsCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = invoice.items;
    final isCash = invoice.isCash;
    final themeColor = isCash ? colors.primary : colors.warning;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس القسم مع شارة إجمالي عدد الكروت ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: themeColor,
                      size: 15.r,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    'بنود كروت الإنترنت المُباعة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  '${invoice.totalCardsCount} كرت إجمالي',
                  style: AppTypography.labelSmall.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(
                child: Text(
                  'لا توجد تفاصيل بنود باقات مسجلة لهذه الفاتورة',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            )
          else ...[
            // ترويسة الجدول المصغر
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: AppRadius.smRadius,
              ),
              child: Row(
                children: [
                  Text(
                    '#',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'الباقة والكمية المسلّمة',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  AppSpacing.hXs,
                  SizedBox(
                    width: 85.w,
                    child: Text(
                      'الصافي (ر.ي)',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w800,
                        fontSize: 10.sp,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vXs,

            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 12.h,
                thickness: 0.6.h,
                color: colors.outlineVariant.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final unitPrice = AmountFormatter.formatValue(
                  item.voucherPrice,
                );
                final lineTotal = AmountFormatter.formatValue(
                  item.itemTotalAmount,
                );

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // رقم البند
                      Container(
                        width: 22.r,
                        height: 22.r,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5.sp,
                          ),
                        ),
                      ),
                      AppSpacing.hSm,

                      // اسم الباقة وسعر الوحدة والخصم
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.packageName?.isNotEmpty == true
                                  ? item.packageName!
                                  : 'باقة كروت #${item.packageId}',
                              style: AppTypography.bodySmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppSpacing.vXxs,
                            Row(
                              children: [
                                Text(
                                  '${item.voucherCount} كرت × $unitPrice ر.ي',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                                ),
                                if (item.itemDiscount > 0) ...[
                                  AppSpacing.hXs,
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: AppRadius.fullRadius,
                                    ),
                                    child: Text(
                                      'خصم: ${AmountFormatter.formatValue(item.itemDiscount)}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 8.5.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.hXs,

                      // المبلغ الصافي بمحاذاة قياسية ثابتة (85.w)
                      SizedBox(
                        width: 85.w,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            lineTotal,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5.sp,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
