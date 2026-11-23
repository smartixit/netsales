import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';

/// مؤشر الوفورات البصري والمقارنة بين الخصم النقدي والآجل (Package Savings Progress Bar)
///
/// يعتمد حصرياً على ألوان المنظومة المركزية [AppColors.success] و [AppColors.info] ومقاسات [AppSpacing] و [AppRadius]
class PackageSavingsProgressBar extends StatelessWidget {
  const PackageSavingsProgressBar({
    super.key,
    required this.cashDiscountPercent,
    required this.creditDiscountPercent,
  });

  final double cashDiscountPercent;
  final double creditDiscountPercent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cashFlex = (cashDiscountPercent * 10).round().clamp(1, 100);
    final creditFlex = (creditDiscountPercent * 10).round().clamp(1, 100);

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding * 0.8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مؤشر التوفير لنقطة البيع عند الشراء بالحزمة',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'خصم نقدي ${cashDiscountPercent.toStringAsFixed(0)}% مقابل آجل ${creditDiscountPercent.toStringAsFixed(0)}%',
                style: AppTypography.badgeText.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: Row(
              children: [
                Expanded(
                  flex: cashFlex,
                  child: Container(
                    height: AppSpacing.sm,
                    color: colors.success,
                  ),
                ),
                SizedBox(width: AppSpacing.xxs),
                Expanded(
                  flex: creditFlex,
                  child: Container(height: AppSpacing.sm, color: colors.info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
