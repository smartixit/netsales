import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';

/// شريط المقارنة المالية والتسعير لبطاقة الباقة (Package Card Pricing Section)
///
/// يدمج الشراء النقدي والشراء الآجل في لوحة صفقات انسيابية ومقروءة للمستخدم
class PackageCardPricingSection extends StatelessWidget {
  const PackageCardPricingSection({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count =
        package.packageVoucherCount > 0 ? package.packageVoucherCount : 1;
    final unitCashSavings = package.cashDiscountAmount / count;

    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // مسار الشراء النقدي (Cash Deal)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'شراء نقدي',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'خصم ${package.packageDefaultCashDiscount.toStringAsFixed(0)}%',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        AmountFormatter.formatValue(package.unitCashPrice),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'ر.ي / كرت',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'وفر ${AmountFormatter.formatValue(unitCashSavings)} بالكرت',
                  style: AppTypography.badgeText.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // فاصل عمودي ناعم
          Container(
            height: 44.h,
            width: 1.w,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),

          // مسار الشراء الآجل (Credit Deal)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'شراء آجل',
                      style: AppTypography.badgeText.copyWith(
                        color: colors.info,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.info.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'خصم ${package.packageDefaultCreditDiscount.toStringAsFixed(0)}%',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.info,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        AmountFormatter.formatValue(package.unitCreditPrice),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'ر.ي / كرت',
                        style: AppTypography.badgeText.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'إجمالي: ${AmountFormatter.formatValue(package.effectiveCreditPrice)}',
                  style: AppTypography.badgeText.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
