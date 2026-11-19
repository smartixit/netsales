import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_order_card_accordion_item_row.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// أكورديون بنود طلب التوريد المتطور (Procurement Order Items Accordion - Executive Edition)
///
/// يعرض قائمة الباقات المطلوبة بنظام الأكورديون الانسيابي (300ms / fastOutSlowIn):
/// - زر التوسيع/الطي المستجيب لكافة المساحة (InkWell).
/// - مؤشرات لونية للباقات وتفاصيل عدد الكروت والأوراق ("ورقة" بدلاً من "شيت").
/// - تمييز مبالغ الخصم والقيمة الإجمالية لكل بند.
/// - إبراز ملاحظات الطلب (إن وجدت).
class ProcurementOrderCardAccordion extends StatelessWidget {
  const ProcurementOrderCardAccordion({
    super.key,
    required this.request,
    required this.packages,
    required this.isExpanded,
    this.onToggle,
  });

  final RequestEntity request;
  final List<PackageEntity> packages;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final itemCount = request.items.length;
    final visibleNames = packages.take(3).map((p) => p.packageName).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isExpanded
              ? colors.primary.withValues(alpha: .35)
              : colors.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط النقر لفتح أو إغلاق الأكورديون
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 10.r),
                child: Row(
                  children: [
                    if (packages.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (
                            var i = 0;
                            i < packages.length.clamp(0, 4);
                            i++
                          ) ...[
                            if (i > 0) AppSpacing.hXxs,
                            Container(
                              width: 5.r,
                              height: 32.r,
                              decoration: BoxDecoration(
                                color: CustomColorPicker.parseHex(
                                  packages[i].packageColor,
                                  fallback: colors.primary,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    if (packages.isNotEmpty) AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            itemCount == 0
                                ? 'لا توجد باقات محددة'
                                : '$itemCount ${itemCount == 1 ? 'باقة' : 'باقات'} • ${request.totalVouchers} كرت',
                            style: AppTypography.labelLarge.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (visibleNames.isNotEmpty && !isExpanded) ...[
                            AppSpacing.vXxs,
                            Text(
                              visibleNames.join(' • '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'إخفاء البنود' : 'عرض البنود',
                          style: AppTypography.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppSpacing.hXxs,
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.fastOutSlowIn,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colors.primary,
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى المتمدد للأكورديون بحركة انسيابية فائقة
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: Alignment.topCenter,
              child: isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(
                          height: 1,
                          color: colors.outlineVariant.withValues(alpha: .4),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.r, 8.r, 12.r, 10.r),
                          child: Column(
                            children: [
                              for (
                                var i = 0;
                                i < request.items.length;
                                i++
                              ) ...[
                                if (i > 0)
                                  Divider(
                                    height: 12.h,
                                    color: colors.outlineVariant.withValues(
                                      alpha: .25,
                                    ),
                                  ),
                                ProcurementOrderCardAccordionItemRow(
                                  item: request.items[i],
                                ),
                              ],
                              if (request.requestNote != null &&
                                  request.requestNote!.trim().isNotEmpty) ...[
                                AppSpacing.vSm,
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.r,
                                    vertical: 6.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: .5),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.sticky_note_2_outlined,
                                        size: 13.r,
                                        color: colors.onSurfaceVariant,
                                      ),
                                      AppSpacing.hXxs,
                                      Expanded(
                                        child: Text(
                                          'ملاحظات: ${request.requestNote}',
                                          style: AppTypography.caption.copyWith(
                                            color: colors.onSurfaceVariant,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
