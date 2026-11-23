import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';

/// بطاقة الصفقة والتعرفة التجارية المنفردة للباقة (Package Commercial Deal Card)
///
/// مكون ذري مستقل يعتمد 100% على توكنز النظام المركزية (AppColors, AppSpacing, AppRadius, AppElevation)
class PackageCommercialDealCard extends StatelessWidget {
  const PackageCommercialDealCard({
    super.key,
    required this.title,
    required this.icon,
    required this.themeColor,
    required this.effectivePrice,
    required this.discountPercent,
    required this.savingsAmount,
    required this.unitCardPrice,
  });

  final String title;
  final IconData icon;
  final Color themeColor;
  final double effectivePrice;
  final double discountPercent;
  final double savingsAmount;
  final double unitCardPrice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: AppElevation.tinted(
          context,
          themeColor,
          alpha: 0.12,
          blur: 16,
          dy: 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.xs + AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(icon, size: 16, color: themeColor),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  'خصم ${discountPercent.toStringAsFixed(0)}%',
                  style: AppTypography.badgeText.copyWith(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm),

          Text(
            AmountFormatter.formatValue(effectivePrice),
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'توفير: ${AmountFormatter.formatValue(savingsAmount)}',
                style: AppTypography.badgeText.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(${AmountFormatter.formatValue(unitCardPrice)} للكرت)',
                style: AppTypography.badgeText.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
