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
/// بطاقة بنود باقات الكروت المطلوبة (RequestItemsCard)
/// ============================================================================
/// تعرض جدول الباقات والكميات المحددة في طلب توريد الكروت.
class RequestItemsCard extends StatelessWidget {
  final VoucherRequestEntity request;

  const RequestItemsCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = request.items;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: AppElevation.level1(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    color: colors.primary,
                    size: 18.r,
                  ),
                  AppSpacing.hXs,
                  Text(
                    'الباقات والكميات المطلوبة',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.fullRadius,
                ),
                child: Text(
                  '${request.totalCardsCount} كرت إجمالي',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
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
                  'لا توجد تفاصيل بنود باقات مسجلة بالطلب',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: AppSpacing.md,
                thickness: 0.8,
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final unitPrice = AmountFormatter.formatValue(item.voucherPrice);
                final lineTotal = AmountFormatter.formatValue(item.itemTotalAmount);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.packageName ?? 'باقة كروت #${item.packageId}',
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppSpacing.vXxs,
                          Text(
                            '${item.voucherCount} كرت × $unitPrice ر.ي',
                            style: AppTypography.labelSmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (item.itemDiscount > 0) ...[
                            AppSpacing.vXxs,
                            Text(
                              'خصم ممنوح: ${AmountFormatter.formatValue(item.itemDiscount)} ر.ي',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.secondary,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lineTotal,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ر.ي',
                          style: AppTypography.labelSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
