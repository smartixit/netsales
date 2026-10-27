import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';

/// ============================================================================
/// بطاقة بنود باقات طلب التوريد (RequestItemsCard)
/// ============================================================================
/// تعرض مصفوفة الباقات والكميات المطلوبة مع محاذاة عمودية دقيقة وموحدة.
class RequestItemsCard extends StatelessWidget {
  final VoucherRequestEntity request;

  const RequestItemsCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = request.items;
    final isPending = request.isPending;
    final isApproved = request.isApproved;
    final statusColor = isPending
        ? colors.warning
        : (isApproved ? colors.primary : colors.error);

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
          // ── رأس القسم مع شارة إجمالي عدد الكروت المطلوبة ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 26.r,
                    height: 26.r,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: statusColor,
                      size: 15.r,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    'بنود باقات الكروت المطلوبة',
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
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  '${request.totalCardsCount} كرت مطلوب',
                  style: AppTypography.labelSmall.copyWith(
                    color: statusColor,
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
                  'لا توجد تفاصيل باقات مسجلة لهذا الطلب',
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
                      'الباقة والكمية المطلوبة',
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
                      'التقديري (ر.ي)',
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
              padding: EdgeInsets.zero,
              shrinkWrap: true,
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

                      // اسم الباقة والكمية
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
                            Text(
                              '${item.voucherCount} كرت مطلوب × $unitPrice ر.ي',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      AppSpacing.hXs,

                      // المبلغ التقديري بمحاذاة قياسية ثابتة (85.w)
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
