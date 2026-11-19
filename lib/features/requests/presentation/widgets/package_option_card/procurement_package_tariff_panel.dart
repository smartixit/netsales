import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/widgets/package_option_card/procurement_package_price_option_card.dart';

/// لوحة تسعير الباقة (الأسعار الأساسية والنقدية والآجلة)
class ProcurementPackageTariffPanel extends StatelessWidget {
  const ProcurementPackageTariffPanel({
    super.key,
    required this.basePrice,
    required this.cashPrice,
    required this.creditPrice,
    required this.cashDiscount,
    required this.creditDiscount,
    required this.isCashSale,
    required this.isDiscountLoading,
    required this.money,
    required this.currency,
  });

  final double basePrice;
  final double cashPrice;
  final double creditPrice;
  final double cashDiscount;
  final double creditDiscount;
  final bool isCashSale;
  final bool isDiscountLoading;
  final String Function(num) money;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 8.r),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .58)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 6.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .26),
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: .48),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sell_outlined,
                  size: 13.r,
                  color: colors.onSurfaceVariant,
                ),
                AppSpacing.hXxs,
                Expanded(
                  child: Text(
                    'السعر الأساسي قبل الخصم',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${money(basePrice)} $currency',
                    textDirection: TextDirection.rtl,
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSm,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProcurementPackagePriceOptionCard(
                  key: const ValueKey('procurement-price-option-cash'),
                  selectedMarkerKey: const ValueKey(
                    'procurement-price-option-cash-selected',
                  ),
                  label: 'السعر النقدي',
                  price: cashPrice,
                  discount: cashDiscount,
                  money: money,
                  currency: currency,
                  selected: isCashSale,
                  isDiscountLoading: isDiscountLoading,
                ),
              ),
              AppSpacing.hXs,
              Expanded(
                child: ProcurementPackagePriceOptionCard(
                  key: const ValueKey('procurement-price-option-credit'),
                  selectedMarkerKey: const ValueKey(
                    'procurement-price-option-credit-selected',
                  ),
                  label: 'السعر الآجل',
                  price: creditPrice,
                  discount: creditDiscount,
                  money: money,
                  currency: currency,
                  selected: !isCashSale,
                  isDiscountLoading: isDiscountLoading,
                  isSecond: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
