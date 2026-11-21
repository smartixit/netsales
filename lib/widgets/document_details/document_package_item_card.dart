import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/badges/custom_chip.dart';
import 'package:netsales/widgets/document_details/custom_document_item_card.dart';

/// بطاقة عرض بند باقة الكروت الموحدة للمعاملات والوثائق الرسمية (DocumentPackageItemCard)
///
/// تمثل المكون المشترك المعتمد لعرض بنود الباقات في شاشات التفاصيل (طلبات التوريد، الفواتير، عروض الأسعار):
/// - هوية الباقة اللونية والترقيم المرجعي واسم الفئة.
/// - كبسولات المواصفات الفنية المعتمدة (الرصيد، الصلاحية، وقت العمل).
/// - سكة الكميات المزدوجة (عدد الكروت، عدد الأوراق، ووصف التوزيع الورقي).
/// - سكة التسعير والخصم المزدوجة (سعر الوحدة، شارة الخصم التعاقدي أو الخاص).
/// - أكورديون تفاعلي لحسبة التدقيق المالي للبند (القيمة الأساسية، الخصم الممنوح، الصافي المستحق).
class DocumentPackageItemCard extends StatelessWidget {
  final int index;
  final String title;
  final String? subtitle;
  final String? colorHex;
  final double totalAmount;
  final int voucherCount;
  final String formattedSheetsCount;
  final String sheetDescription;
  final double voucherPrice;
  final bool hasDiscount;
  final double itemDiscount;
  final bool isCustomDiscount;
  final String? discountLabel;
  final String? balanceDisplay;
  final String? validityDisplay;
  final String? uptimeDisplay;
  final String quantityLabel;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final List<DocumentItemAuditRowData>? customAuditRows;

  const DocumentPackageItemCard({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.colorHex,
    required this.totalAmount,
    required this.voucherCount,
    required this.formattedSheetsCount,
    required this.sheetDescription,
    required this.voucherPrice,
    this.hasDiscount = false,
    this.itemDiscount = 0.0,
    this.isCustomDiscount = false,
    this.discountLabel,
    this.balanceDisplay,
    this.validityDisplay,
    this.uptimeDisplay,
    this.quantityLabel = 'الكمية المطلوبة',
    this.isExpanded = false,
    this.onToggleExpand,
    this.customAuditRows,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final resolvedDiscountLabel = discountLabel ??
        (isCustomDiscount
            ? 'خصم خاص'
            : (hasDiscount ? 'خصم تعاقدي' : null));

    final effectiveAuditRows = customAuditRows ??
        [
          DocumentItemAuditRowData(
            label: 'القيمة الإجمالية الأساسية',
            formula:
                '$voucherCount كرت × ${AmountFormatter.formatValue(voucherPrice)}',
            amount: AmountFormatter.formatValue(voucherCount * voucherPrice),
          ),
          if (hasDiscount)
            DocumentItemAuditRowData(
              label: isCustomDiscount
                  ? 'الخصم الخاص الممنوح (مخصص لنقطتك)'
                  : 'الخصم الافتراضي للباقة (تعاقدي)',
              amount: '-${AmountFormatter.formatValue(itemDiscount)}',
              isDiscount: true,
            ),
          DocumentItemAuditRowData(
            label: 'صافي القيمة المستحقة للبند',
            amount: AmountFormatter.formatValue(totalAmount),
            isTotal: true,
          ),
        ];

    return CustomDocumentItemCard(
      index: index,
      title: title,
      subtitle: subtitle ?? 'سعة الورقة: ${sheetDescription.isNotEmpty ? sheetDescription : "$voucherCount كرت"}',
      colorHex: colorHex,
      totalAmountFormatted: AmountFormatter.formatValue(totalAmount),
      totalAmountSubtitle: 'الصافي',
      isExpanded: isExpanded,
      onToggleExpand: onToggleExpand,
      auditRows: effectiveAuditRows,
      specBadges: [
        if (balanceDisplay != null && balanceDisplay!.isNotEmpty)
          CustomChip(
            label: balanceDisplay!,
            icon: Icons.data_usage_rounded,
            isCompact: true,
          ),
        if (validityDisplay != null && validityDisplay!.isNotEmpty)
          CustomChip(
            label: validityDisplay!,
            icon: Icons.calendar_today_rounded,
            isCompact: true,
          ),
        if (uptimeDisplay != null && uptimeDisplay!.isNotEmpty)
          CustomChip(
            label: uptimeDisplay!,
            icon: Icons.timer_outlined,
            isCompact: true,
          ),
      ],
      primaryMetric: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_none_rounded,
                  size: 12.r,
                  color: colors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  quantityLabel,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$voucherCount كرت',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '($formattedSheetsCount ورقة)',
                    style: AppTypography.caption.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              sheetDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 9.5.sp,
              ),
            ),
          ],
        ),
      ),
      secondaryMetric: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 12.r,
                  color: hasDiscount
                      ? (isCustomDiscount ? colors.success : colors.skyAccent)
                      : colors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  'سعر الكرت',
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                AmountFormatter.formatValue(voucherPrice),
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            if (hasDiscount)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (isCustomDiscount ? colors.success : colors.skyAccent)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCustomDiscount
                            ? Icons.storefront_rounded
                            : Icons.auto_awesome_rounded,
                        size: 10.r,
                        color: isCustomDiscount
                            ? colors.success
                            : colors.skyAccent,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '$resolvedDiscountLabel: ${AmountFormatter.formatValue(itemDiscount)}',
                        style: AppTypography.caption.copyWith(
                          color: isCustomDiscount
                              ? colors.success
                              : colors.skyAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Text(
                'سعر أساسي بدون خصم',
                style: AppTypography.caption.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 9.5.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
