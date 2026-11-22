import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/document_details/models/document_item_audit_row_data.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

export 'package:netsales/widgets/document_details/models/document_item_audit_row_data.dart';

/// بطاقة الباقة/البند التفصيلي الموحدة (CustomDocumentItemCard)
///
/// المرجع المعتمد لعرض بنود المعاملات في شاشات التفاصيل (الطلبات، الفواتير، عروض الأسعار):
/// - إطار فاخر بحواف 20.r مع تدرج لوني خفيف من هوية الباقة وظلال مزدوجة.
/// - ترويسة البند بشارة الترقيم الملونة (#1, #2)، اسم الباقة، وسعر الوحدة والصافي.
/// - كبسولات المواصفات الفنية (الرصيد، الصلاحية، وقت العمل).
/// - سكتان قياسيتان مزدوجتان (الكميات والأوراق VS سعر الكرت والخصم).
/// - أكورديون تفاعلي بحركة انسيابية فائقة (AnimatedSize + ClipRect) لعرض التدقيق المالي والحسبة.
class CustomDocumentItemCard extends StatelessWidget {
  const CustomDocumentItemCard({
    super.key,
    required this.index,
    required this.title,
    this.subtitle,
    this.colorHex,
    required this.totalAmountFormatted,
    this.totalAmountSubtitle = 'الصافي',
    this.specBadges = const [],
    this.primaryMetric,
    this.secondaryMetric,
    this.isExpanded = false,
    this.onToggleExpand,
    this.auditRows,
    this.expandLabel = 'عرض تفاصيل الحسبة والتدقيق المالي للبند',
    this.collapseLabel = 'إخفاء تفاصيل التدقيق المالي',
  });

  final int index;
  final String title;
  final String? subtitle;
  final String? colorHex;
  final String totalAmountFormatted;
  final String totalAmountSubtitle;
  final List<Widget> specBadges;
  final Widget? primaryMetric;
  final Widget? secondaryMetric;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final List<DocumentItemAuditRowData>? auditRows;
  final String expandLabel;
  final String collapseLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = CustomColorPicker.parseHex(
      colorHex,
      fallback: colors.primary,
    );

    final hasAccordion = auditRows != null && auditRows!.isNotEmpty;

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
              onTap: hasAccordion ? onToggleExpand : null,
              splashColor: accentColor.withValues(alpha: 0.08),
              highlightColor: accentColor.withValues(alpha: 0.04),
              child: Padding(
                padding: EdgeInsets.fromLTRB(14.r, 14.r, 14.r, 10.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // شارة رقم الباقة
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

                    // اسم الباقة والمعلومات الفرعية
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 3.h),
                            Text(
                              subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AppSpacing.hSm,

                    // كبسولة الإجمالي الصافي
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
                              totalAmountFormatted,
                              style: AppTypography.labelLarge.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            totalAmountSubtitle,
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

          // ── 2. شريط كبسولات المواصفات ──
          if (specBadges.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              child: Wrap(spacing: 6.w, runSpacing: 4.h, children: specBadges),
            ),
            SizedBox(height: 10.h),
          ],

          // ── 3. السكك القياسية المزدوجة ──
          if (primaryMetric != null || secondaryMetric != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.r),
              child: Row(
                children: [
                  if (primaryMetric != null) Expanded(child: primaryMetric!),
                  if (primaryMetric != null && secondaryMetric != null)
                    SizedBox(width: 8.w),
                  if (secondaryMetric != null)
                    Expanded(child: secondaryMetric!),
                ],
              ),
            ),
          ],

          // ── 4. المحتوى المتمدد للأكورديون بحركة انسيابية فائقة ──
          if (hasAccordion)
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
                                        style: AppTypography.labelMedium
                                            .copyWith(
                                              color: colors.onSurface,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  for (
                                    var i = 0;
                                    i < auditRows!.length;
                                    i++
                                  ) ...[
                                    if (i > 0) SizedBox(height: 6.h),
                                    if (auditRows![i].isTotal) ...[
                                      Divider(
                                        height: 1,
                                        color: colors.outlineVariant.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                      SizedBox(height: 6.h),
                                    ],
                                    _AuditRowWidget(row: auditRows![i]),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),

          // ── 5. شريط النقر لفتح أو إغلاق الأكورديون ──
          if (hasAccordion)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onToggleExpand,
                splashColor: accentColor.withValues(alpha: 0.08),
                highlightColor: accentColor.withValues(alpha: 0.04),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.r,
                    vertical: 9.h,
                  ),
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
                          isExpanded ? collapseLabel : expandLabel,
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
            )
          else ...[
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _AuditRowWidget extends StatelessWidget {
  const _AuditRowWidget({required this.row});

  final DocumentItemAuditRowData row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                row.label,
                style: row.isTotal
                    ? AppTypography.labelMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      )
                    : AppTypography.caption.copyWith(
                        color: row.isDiscount
                            ? colors.error
                            : colors.onSurfaceVariant,
                        fontWeight: row.isDiscount
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
              ),
              if (row.formula != null) ...[
                SizedBox(height: 1.h),
                Text(
                  row.formula!,
                  style: AppTypography.caption.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 9.5.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.hSm,
        Text(
          row.amount,
          style: row.isTotal
              ? AppTypography.labelLarge.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                )
              : AppTypography.labelMedium.copyWith(
                  color: row.isDiscount ? colors.error : colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
        ),
      ],
    );
  }
}
