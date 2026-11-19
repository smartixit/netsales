import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/domain/entities/request_item_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_audit_row.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_details_spec_badge.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// بطاقة الباقة التوريدية المتطورة بنظام حركة الأكورديون المعتمد لصفحة الطلبات
///
/// تجسد المعايير العالمية في عرض بنود طلبات التوريد:
/// - أسلوب حركة الأكورديون المطابق تماماً لبطاقات الطلبات (AnimatedSize + ClipRect بمدة 280ms و Curve.easeInOutCubic).
/// - نظام أكورديون حصري ينسجم مع نمط صفحة الطلبات (فتح بند يغلق الآخر بنعومة تامة).
/// - توضيح نوع الخصم المعتمد بدقة (خصم خاص بنقطة البيع VS خصم افتراضي تعاقدي).
/// - سكك قياسية متوازنة للكمية، توزيع الشيتات، وسعر الكرت والخصم مع حماية تامة ضد التجاوز.
class ProcurementDetailsItemCard extends StatelessWidget {
  const ProcurementDetailsItemCard({
    super.key,
    required this.item,
    required this.index,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  final RequestItemEntity item;
  final int index;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final package = item.voucherPackage;

    // استخراج لون الباقة مع لون احتياطي معتمد
    final accentColor = CustomColorPicker.parseHex(
      package?.packageColor,
      fallback: colors.primary,
    );

    final packageName = item.packageName;
    final sheetSize = item.sheetSize;
    final sheetDescription = item.sheetDescription;
    final sheetsFormatted = item.formattedSheetsCount;
    final grossAmount = item.grossAmount;
    final hasDiscount = item.hasDiscount;
    final isCustomDiscount = item.isCustomDiscount;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            accentColor.withValues(alpha: isExpanded ? 0.08 : 0.035),
            colors.surface,
            colors.surface,
          ],
          stops: const [0.0, 0.40, 1.0],
        ),
        border: Border.all(
          color: isExpanded
              ? accentColor.withValues(alpha: 0.45)
              : colors.outlineVariant.withValues(alpha: 0.35),
          width: isExpanded ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isExpanded ? 0.09 : 0.04),
            blurRadius: isExpanded ? 18 : 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 1. ترويسة هوية الباقة والترقيم والقيمة الصافية ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleExpand,
              splashColor: accentColor.withValues(alpha: 0.08),
              highlightColor: accentColor.withValues(alpha: 0.04),
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 10.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // شارة رقم الباقة وهوية لونها الفاخر
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            accentColor.withValues(alpha: 0.20),
                            accentColor.withValues(alpha: 0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.38),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.16),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Text(
                            '#${index + 1}',
                            style: AppTypography.titleSmall.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hSm,

                    // اسم الباقة ومعلومات الشبكة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            packageName,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Icon(
                                Icons.layers_outlined,
                                size: 11.5.r,
                                color: colors.onSurfaceVariant,
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  'سعة الورقة: $sheetSize كرت',
                                  style: AppTypography.caption.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,

                    // كبسولة الإجمالي الصافي للبند
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AmountFormatter.formatValue(item.itemTotalAmount),
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'الصافي',
                            style: AppTypography.caption.copyWith(
                              color: colors.primary.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 2. شريط كبسولات مواصفات الباقة ──
          if (package != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: [
                  if (package.packageBalance > 0)
                    ProcurementDetailsSpecBadge(
                      label: package.balanceDisplay,
                      icon: Icons.data_usage_rounded,
                      tintColor: colors.skyAccent,
                    ),
                  if (package.packageValidity != null)
                    ProcurementDetailsSpecBadge(
                      label: package.validityDisplay,
                      icon: Icons.calendar_today_rounded,
                      tintColor: colors.amberAccent,
                    ),
                  if (package.packageUptime != null)
                    ProcurementDetailsSpecBadge(
                      label: package.uptimeDisplay,
                      icon: Icons.timer_outlined,
                      tintColor: colors.purpleAccent,
                    ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
          ],

          // ── 3. السكك القياسية المزدوجة (الكمية والأوراق VS سعر الكرت والخصم) ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.r),
            child: Row(
              children: [
                // سكة الكمية وتوزيع الشيتات
                Expanded(
                  child: Container(
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
                              'الكمية المطلوبة',
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
                                '${item.voucherCount} كرت',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '($sheetsFormatted ورقة)',
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
                ),
                SizedBox(width: 8.w),

                // سكة سعر الكرت والخصم التجاري مع تمييز (خصم خاص VS خصم افتراضي)
                Expanded(
                  child: Container(
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
                                  ? (isCustomDiscount
                                        ? colors.success
                                        : colors.skyAccent)
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
                            AmountFormatter.formatValue(item.voucherPrice),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isCustomDiscount
                                            ? colors.success
                                            : colors.skyAccent)
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
                                    '${isCustomDiscount ? 'خصم خاص' : 'خصم افتراضي'}: ${AmountFormatter.formatValue(item.itemDiscount)}',
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
                ),
              ],
            ),
          ),

          // ── 4. المحتوى المتمدد للأكورديون بحركة انسيابية فائقة (AnimatedSize + ClipRect) ──
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 12.h),
                        Divider(
                          height: 1,
                          color: accentColor.withValues(alpha: 0.20),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(14.r, 12.r, 14.r, 6.r),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 14.r,
                                      color: accentColor,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'تفاصيل الحسبة والتدقيق المالي للبند',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),

                                ProcurementDetailsAuditRow(
                                  label: 'القيمة الإجمالية الأساسية',
                                  formula:
                                      '${item.voucherCount} كرت × ${AmountFormatter.formatValue(item.voucherPrice)}',
                                  amount: AmountFormatter.formatValue(
                                    grossAmount,
                                  ),
                                ),

                                if (hasDiscount) ...[
                                  SizedBox(height: 6.h),
                                  ProcurementDetailsAuditRow(
                                    label: isCustomDiscount
                                        ? 'الخصم الخاص الممنوح (مخصص لنقطتك)'
                                        : 'الخصم الافتراضي للباقة (تعاقدي)',
                                    amount:
                                        '-${AmountFormatter.formatValue(item.itemDiscount)}',
                                    isDiscount: true,
                                  ),
                                ],

                                SizedBox(height: 6.h),
                                Divider(
                                  height: 1,
                                  color: colors.outlineVariant.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                ProcurementDetailsAuditRow(
                                  label: 'صافي القيمة المستحقة للبند',
                                  amount: AmountFormatter.formatValue(
                                    item.itemTotalAmount,
                                  ),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // ── 5. شريط النقر لفتح أو إغلاق الأكورديون (باستخدام InkWell لضمان استجابة كل البكسلات للنقر) ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggleExpand,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 9.h),
                child: Row(
                  children: [
                    Icon(
                      isExpanded
                          ? Icons.unfold_less_rounded
                          : Icons.unfold_more_rounded,
                      size: 14.r,
                      color: accentColor,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        isExpanded
                            ? 'إخفاء تفاصيل التدقيق المالي'
                            : 'عرض تفاصيل الحسبة والتدقيق المالي للبند',
                        style: AppTypography.caption.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20.r,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
