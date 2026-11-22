import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';

/// شريط قياس القدرة الشرائية والتسهيل الائتماني لمحفظة نقطة البيع (Purchasing Power Gauge)
class PosWalletPurchasingPowerGauge extends StatelessWidget {
  const PosWalletPurchasingPowerGauge({super.key, required this.wallet});

  final PosWalletEntity wallet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final creditLimitFormatted = wallet.creditLimit != null
        ? AmountFormatter.format(wallet.creditLimit!.toStringAsFixed(2))
        : 'غير محدد';
    final overdraftFormatted = AmountFormatter.format(
      wallet.availableOverdraftCapacity.toStringAsFixed(2),
    );
    final purchasingPowerFormatted = AmountFormatter.format(
      wallet.totalPurchasingPower.toStringAsFixed(2),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // 1. السقف الائتماني
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'السقف الائتماني',
                  maxLines: 1,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  creditLimitFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.executiveGoldAccent,
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ],
            ),
          ),

          // فاصل رأسي
          Container(
            height: 28.h,
            width: 1.w,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(width: AppSpacing.sm),

          // 2. المتبقي على المكشوف
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'المتاح على المكشوف',
                  maxLines: 1,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  overdraftFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: AppTypography.semiBold,
                  ),
                ),
              ],
            ),
          ),

          // فاصل رأسي
          Container(
            height: 28.h,
            width: 1.w,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(width: AppSpacing.sm),

          // 3. إجمالي القدرة الشرائية
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إجمالي القدرة الشرائية',
                  maxLines: 1,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  purchasingPowerFormatted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleSmall.copyWith(
                    color: const Color(0xFF5EEAD4),
                    fontWeight: AppTypography.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
