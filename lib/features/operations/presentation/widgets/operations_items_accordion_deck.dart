import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// كائن بيانات بند العملية الموحد للدرج المنسدل (OperationAccordionItem)
/// ============================================================================
class OperationAccordionItem {
  final String packageName;
  final int voucherCount;
  final double voucherPrice;
  final double itemDiscount;
  final double itemTotalAmount;

  const OperationAccordionItem({
    required this.packageName,
    required this.voucherCount,
    required this.voucherPrice,
    required this.itemDiscount,
    required this.itemTotalAmount,
  });

  factory OperationAccordionItem.fromInvoiceItem(SaleInvoiceItemEntity item) {
    return OperationAccordionItem(
      packageName: item.packageName?.isNotEmpty == true
          ? item.packageName!
          : 'باقة كروت #${item.packageId}',
      voucherCount: item.voucherCount,
      voucherPrice: item.voucherPrice,
      itemDiscount: item.itemDiscount,
      itemTotalAmount: item.itemTotalAmount,
    );
  }

  factory OperationAccordionItem.fromRequestItem(
    VoucherRequestItemEntity item,
  ) {
    return OperationAccordionItem(
      packageName: item.packageName?.isNotEmpty == true
          ? item.packageName!
          : 'باقة كروت #${item.packageId}',
      voucherCount: item.voucherCount,
      voucherPrice: item.voucherPrice,
      itemDiscount: item.itemDiscount,
      itemTotalAmount: item.itemTotalAmount,
    );
  }
}

/// ============================================================================
/// درج تفكيك الباقات المنسدل الأكورديون (OperationsItemsAccordionDeck)
/// ============================================================================
/// يعرض تفاصيل الباقات المضمنة في السند المالي بشكل انسيابي فائق النعومة،
/// يوضح توزيع الكميات والأسعار والخصومات لكل باقة دون مغادرة السجل الرئيسي.
class OperationsItemsAccordionDeck extends StatelessWidget {
  final List<OperationAccordionItem> items;
  final Color themeColor;
  final VoidCallback? onDetailsTap;

  const OperationsItemsAccordionDeck({
    super.key,
    required this.items,
    required this.themeColor,
    this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ترويسة مصغرة للدرج مع محاذاة عمودية هندسية دقيقة
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 13.r,
                      color: themeColor,
                    ),
                    AppSpacing.hXxs,
                    Flexible(
                      child: Text(
                        'تفاصيل الباقات (${items.length})',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.hXs,
              SizedBox(
                width: 85.w,
                child: Text(
                  'الصافي',
                  textAlign: TextAlign.end,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 9.5.sp,
                  ),
                ),
              ),
            ],
          ),

          Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            height: 0.6.h,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),

          // بنود الباقات مصفوفة بمحاذاة تامة مع عمود الصافي
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final formattedItemTotal = AmountFormatter.formatValue(
              item.itemTotalAmount,
            );
            final hasDiscount = item.itemDiscount > 0.001;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0)
                    Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      height: 0.5.h,
                      color: colors.outlineVariant.withValues(alpha: 0.15),
                    ),
                  // السطر الأول: النقطة واسم الباقة وصافي القيمة بمحاذاة دقيقة
                  Row(
                    children: [
                      Container(
                        width: 5.r,
                        height: 5.r,
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      AppSpacing.hXs,
                      Expanded(
                        child: Text(
                          item.packageName,
                          style: AppTypography.labelMedium.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                      AppSpacing.hXs,
                      SizedBox(
                        width: 85.w,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '$formattedItemTotal ر.ي',
                            textAlign: TextAlign.end,
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vXxs,
                  // السطر الثاني: الكمية ونسبة الخصم
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 11.w),
                    child: Text(
                      '${item.voucherCount} كرت${hasDiscount ? " • خصم ${item.itemDiscount.toStringAsFixed(item.itemDiscount.truncateToDouble() == item.itemDiscount ? 0 : 1)}%" : ""}',
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),

          // رابط الانتقال السريع للتفاصيل الكاملة
          if (onDetailsTap != null) ...[
            Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              height: 0.6.h,
              color: colors.outlineVariant.withValues(alpha: 0.25),
            ),
            CustomInteractiveBounce(
              onTap: onDetailsTap!,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'عرض السند المالي الكامل والتفاصيل',
                        style: AppTypography.labelSmall.copyWith(
                          color: themeColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.hXxs,
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 11.r,
                      color: themeColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
