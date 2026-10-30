import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_items_accordion_deck.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// سند فاتورة المبيعات السيادي الفاخر (SaleInvoiceLedgerTile)
/// ============================================================================
/// يجسد فاتورة المبيعات كسند مالي سيادي فاخر (Sovereign Financial Bond)،
/// يدعم التوسيع الأكورديوني المنسدل السلس (Accordion Inline Expand) لعرض تفاصيل
/// الباقات المضمنة فوراً دون مغادرة السجل الرئيسي، مع تصميم تكيفي عالي الدقة.
class SaleInvoiceLedgerTile extends StatelessWidget {
  final SaleInvoiceEntity invoice;
  final VoidCallback onTap;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const SaleInvoiceLedgerTile({
    super.key,
    required this.invoice,
    required this.onTap,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCash = invoice.isCash;
    final isFullyPaid = invoice.isFullyPaid;
    final formattedTotal = AmountFormatter.formatValue(
      invoice.invoiceTotalAmount,
    );
    final formattedRemaining = AmountFormatter.formatValue(
      invoice.remainingAmount,
    );

    final dt = DateFormatter.tryParse(
      invoice.invoiceDate ?? invoice.createdAt ?? '',
    );
    final dateStr = dt != null
        ? DateFormatter.dateTime(dt)
        : (invoice.invoiceDate ?? '');

    // اللون المحوري للحركة المالية (نقدي زمردي / آجل كهرماني)
    final themeColor = isCash ? colors.primary : colors.warning;

    // تجهيز النص التكيفي للباقات
    final hasMultiplePackages = invoice.items.length > 1;
    final String packageSummaryText;
    if (invoice.items.isEmpty) {
      packageSummaryText = isCash ? 'بيع نقدي' : 'بيع آجل';
    } else if (invoice.items.length == 1) {
      final item = invoice.items.first;
      final pkgName = item.packageName?.isNotEmpty == true
          ? item.packageName!
          : 'باقة كروت';
      packageSummaryText =
          '$pkgName (${item.voucherCount} كرت) • ${isCash ? "بيع نقدي" : "بيع آجل"}';
    } else {
      packageSummaryText =
          '${invoice.items.length} باقات مختلفة (${invoice.totalCardsCount} كرت) • ${isCash ? "بيع نقدي" : "بيع آجل"}';
    }

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgRadius,
          boxShadow: AppElevation.level1(context),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.lgRadius,
          child: Stack(
            children: [
              // وعاء البطاقة الأساسي مع التوهج المحيطي الناعم
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.ledgerHero3(context, themeColor),
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.28),
                    width: 1.w,
                  ),
                ),
                padding: EdgeInsetsDirectional.only(
                  start: 16.w,
                  end: 14.w,
                  top: 12.h,
                  bottom: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. الترويسة التنفيذية: هوية نقطة البيع وشارة الحالة الموحدة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة نقطة البيع بوعاء سكويركل ذو توهج لوني
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            gradient: AppGradients.ledgerBadge(
                              context,
                              themeColor,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.25),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.storefront_rounded,
                            color: themeColor,
                            size: 19.r,
                          ),
                        ),
                        AppSpacing.hSm,
                        // اسم نقطة البيع وبيانات السند المرجعية
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.posName ?? 'نقطة بيع #${invoice.posId}',
                                style: AppTypography.titleSmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              AppSpacing.vXxs,
                              Text(
                                dateStr.isNotEmpty
                                    ? '#${invoice.invoiceUuid} • $dateStr'
                                    : '#${invoice.invoiceUuid}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hXs,
                        // كبسولة حالة السداد الزجاجية الموحدة
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isFullyPaid
                                          ? colors.primary
                                          : colors.warning)
                                      .withValues(alpha: 0.1),
                              borderRadius: AppRadius.fullRadius,
                              border: Border.all(
                                color:
                                    (isFullyPaid
                                            ? colors.primary
                                            : colors.warning)
                                        .withValues(alpha: 0.25),
                                width: 0.8.w,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5.5.r,
                                  height: 5.5.r,
                                  decoration: BoxDecoration(
                                    color: isFullyPaid
                                        ? colors.primary
                                        : colors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                AppSpacing.hXxs,
                                Flexible(
                                  child: Text(
                                    isFullyPaid
                                        ? 'مسددة'
                                        : (invoice.remainingAmount > 0
                                              ? 'متبقي: $formattedRemaining'
                                              : 'آجل'),
                                    style: AppTypography.labelSmall.copyWith(
                                      color: isFullyPaid
                                          ? colors.primary
                                          : colors.warning,
                                      fontWeight: FontWeight.w800,
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
                      ],
                    ),

                    // 2. الفاصل البصري الشعري الناعم
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      height: 0.8.h,
                      decoration: BoxDecoration(
                        gradient: AppGradients.outlineSoft(
                          context,
                          colors.outlineVariant,
                        ),
                      ),
                    ),

                    // 3. الرصيف المالي والمكاني: المبلغ الإجمالي والمعلومات الفرعية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // الرقم المالي المحوري وتفاصيل البيع
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      formattedTotal,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18.sp,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    AppSpacing.hXxs,
                                    Text(
                                      'ر.ي',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.vXxs,
                              Text(
                                packageSummaryText,
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.hXs,
                        // أزرار الإجراء: كبسولة طي/عرض البنود ومؤشر الانتقال للتفاصيل
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasMultiplePackages) ...[
                              CustomInteractiveBounce(
                                onTap: () => onToggleExpand?.call(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: themeColor.withValues(alpha: 0.08),
                                    borderRadius: AppRadius.fullRadius,
                                    border: Border.all(
                                      color: themeColor.withValues(alpha: 0.25),
                                      width: 0.8.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isExpanded ? 'طي البنود' : 'عرض البنود',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: themeColor,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 9.5.sp,
                                            ),
                                      ),
                                      AppSpacing.hXxs,
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        size: 13.r,
                                        color: themeColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AppSpacing.hXs,
                            ],
                            // مؤشر الانتقال للتفاصيل
                            Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest
                                    .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11.r,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 4. درج تفكيك الباقات المنسدل الأكورديون المدمج
                    if (hasMultiplePackages)
                      AnimatedSize(
                        duration: AppMotion.normal,
                        curve: AppMotion.standard,
                        alignment: Alignment.topCenter,
                        child: isExpanded
                            ? OperationsItemsAccordionDeck(
                                items: invoice.items
                                    .map(OperationAccordionItem.fromInvoiceItem)
                                    .toList(),
                                themeColor: themeColor,
                                onDetailsTap: onTap,
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),

              // شريط الهوية السيادي الجانبي ممتد على كامل الحافة وبنفس انحناء زوايا الكرت
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4.w, color: themeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
