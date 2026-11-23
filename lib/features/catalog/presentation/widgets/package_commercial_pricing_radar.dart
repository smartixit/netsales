import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_commercial_deal_card.dart';
import 'package:netsales/features/catalog/presentation/widgets/package_savings_progress_bar.dart';

/// رادار المقارنة المالية والتجارية للباقة (Package Commercial Pricing Radar)
///
/// يعتمد حصرياً على ألوان المنظومة المركزية [AppColors.success] و [AppColors.info] ومقاسات [AppSpacing] و [AppRadius]
class PackageCommercialPricingRadar extends StatelessWidget {
  const PackageCommercialPricingRadar({super.key, required this.package});

  final PackageEntity package;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.price_change_outlined,
                  size: 20,
                  color: colors.primary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'التعرفة والخصومات التعاقدية المعتمدة',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + AppSpacing.xxs,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                'الأساس: ${AmountFormatter.formatValue(package.packageVoucherPrice)}',
                style: AppTypography.badgeText.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),

        // بطاقات المقارنة الثنائية (نقداً vs آجلاً)
        Row(
          children: [
            // مسار الشراء النقدي باستخدام لون النجاح المركزي
            Expanded(
              child: PackageCommercialDealCard(
                title: 'شراء نقدي',
                icon: Icons.payments_rounded,
                themeColor: colors.success,
                effectivePrice: package.effectiveCashPrice,
                discountPercent: package.packageDefaultCashDiscount,
                savingsAmount: package.cashDiscountAmount,
                unitCardPrice: package.unitCashPrice,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            // مسار الشراء الآجل باستخدام اللون الإرشادي المركزي
            Expanded(
              child: PackageCommercialDealCard(
                title: 'شراء آجل (ائتماني)',
                icon: Icons.credit_score_rounded,
                themeColor: colors.info,
                effectivePrice: package.effectiveCreditPrice,
                discountPercent: package.packageDefaultCreditDiscount,
                savingsAmount: package.creditDiscountAmount,
                unitCardPrice: package.unitCreditPrice,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.md),

        // شريط المقارنة البصري للوفورات (Visual Savings Meter)
        PackageSavingsProgressBar(
          cashDiscountPercent: package.packageDefaultCashDiscount,
          creditDiscountPercent: package.packageDefaultCreditDiscount,
        ),
      ],
    );
  }
}
