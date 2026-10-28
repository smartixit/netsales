import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_motion.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/core/utils/date_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/presentation/widgets/operations_items_accordion_deck.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// سند طلب التوريد السيادي الفاخر (VoucherRequestLedgerTile)
/// ============================================================================
/// يجسد طلب توريد الكروت كسند سيادي فاخر (Sovereign Financial Bond)،
/// يدعم التوسيع الأكورديوني المنسدل السلس (Accordion Inline Expand) لعرض تفاصيل
/// الباقات المضمنة فوراً دون مغادرة السجل الرئيسي، مع تصميم تكيفي عالي الدقة.
class VoucherRequestLedgerTile extends StatelessWidget {
  final VoucherRequestEntity request;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const VoucherRequestLedgerTile({
    super.key,
    required this.request,
    required this.onTap,
    this.onApprove,
    this.onReject,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPending = request.isPending;
    final isApproved = request.isApproved;
    final isRejected = request.isRejected;
    final formattedTotal = AmountFormatter.formatValue(
      request.requestTotalAmount,
    );

    final dt = DateFormatter.tryParse(request.requestDate ?? request.createdAt ?? '');
    final dateStr = dt != null ? DateFormatter.dateTime(dt) : '';

    // لون حالة التوريد
    final statusColor = isPending
        ? colors.warning
        : (isApproved
              ? colors.primary
              : (isRejected ? colors.error : colors.onSurfaceVariant));

    // تجهيز النص التكيفي للباقات
    final hasMultiplePackages = request.items.length > 1;
    final String packageSummaryText;
    if (request.items.isEmpty) {
      packageSummaryText = request.isCash ? 'دفع نقدي' : 'دفع آجل';
    } else if (request.items.length == 1) {
      final item = request.items.first;
      final pkgName = item.packageName?.isNotEmpty == true
          ? item.packageName!
          : 'باقة كروت';
      packageSummaryText =
          '$pkgName (${item.voucherCount} كرت مطلوب) • ${request.isCash ? "دفع نقدي" : "دفع آجل"}';
    } else {
      packageSummaryText =
          '${request.items.length} باقات مطلوبة (${request.totalCardsCount} كرت) • ${request.isCash ? "دفع نقدي" : "دفع آجل"}';
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      statusColor.withValues(alpha: 0.05),
                      colors.surface.withValues(alpha: 0.35),
                      colors.surfaceContainerLowest,
                    ],
                    stops: const [0.0, 0.40, 1.0],
                  ),
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(
                    color: isPending
                        ? colors.warning.withValues(alpha: 0.35)
                        : colors.outlineVariant.withValues(alpha: 0.28),
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
                    // 1. الترويسة التنفيذية: اسم نقطة البيع وشارة الحالة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // أيقونة حالة التوريد سكويركل
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor.withValues(alpha: 0.16),
                                statusColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.25),
                              width: 0.8.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            isPending
                                ? Icons.hourglass_top_rounded
                                : (isApproved
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.cancel_outlined),
                            color: statusColor,
                            size: 19.r,
                          ),
                        ),
                        AppSpacing.hSm,
                        // اسم نقطة البيع ورمز الطلب
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.posName ?? 'نقطة بيع #${request.posId}',
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
                                    ? '#${request.requestUuid} • $dateStr'
                                    : '#${request.requestUuid}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
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
                        // كبسولة حالة الطلب الزجاجية
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 90.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.fullRadius,
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.25),
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
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                AppSpacing.hXxs,
                                Flexible(
                                  child: Text(
                                    request.statusLabel,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: statusColor,
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
                        gradient: LinearGradient(
                          colors: [
                            colors.outlineVariant.withValues(alpha: 0.35),
                            colors.outlineVariant.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),

                    // 3. الرصيف المالي والمكاني: المبلغ الإجمالي وإجراءات القرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // الرقم المالي المحوري وتفاصيل عدد الكروت
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
                        AppSpacing.hXxs,
                        // أزرار الإجراء: كبسولة طي/عرض البنود وأزرار القرار الأيقونية المدمجة
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasMultiplePackages) ...[
                              CustomInteractiveBounce(
                                onTap: () => onToggleExpand?.call(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.08),
                                    borderRadius: AppRadius.fullRadius,
                                    border: Border.all(
                                      color: statusColor.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 0.8.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isExpanded
                                            ? 'طي البنود'
                                            : 'عرض البنود',
                                        style: AppTypography.labelSmall
                                            .copyWith(
                                              color: statusColor,
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
                                        color: statusColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              AppSpacing.hXxs,
                            ],
                            if (isPending &&
                                (onApprove != null ||
                                    onReject != null)) ...[
                              if (onReject != null) ...[
                                CustomButton.icon(
                                  icon: Icons.close_rounded,
                                  dimension: 30.r,
                                  iconSize: 15.r,
                                  foregroundColor: colors.error,
                                  backgroundColor: colors.error.withValues(
                                    alpha: 0.1,
                                  ),
                                  tooltip: 'رفض الطلب',
                                  onPressed: onReject!,
                                ),
                                AppSpacing.hXxs,
                              ],
                              if (onApprove != null)
                                CustomButton.icon(
                                  icon: Icons.check_rounded,
                                  dimension: 30.r,
                                  iconSize: 15.r,
                                  foregroundColor: colors.primary,
                                  backgroundColor: colors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  tooltip: 'اعتماد الطلب',
                                  onPressed: onApprove!,
                                ),
                            ] else ...[
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
                                items: request.items
                                    .map(OperationAccordionItem.fromRequestItem)
                                    .toList(),
                                themeColor: statusColor,
                                onDetailsTap: onTap,
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),

              // شريط الحالة السيادي الجانبي ممتد على كامل الحافة وبنفس انحناء زوايا الكرت
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4.w, color: statusColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
