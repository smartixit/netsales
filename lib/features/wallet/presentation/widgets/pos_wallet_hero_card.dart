import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/features/wallet/presentation/widgets/pos_wallet_purchasing_power_gauge.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة المحفظة المالية التنفيذية الفاخرة (POS Wallet Executive Hero Card)
///
/// تستخدم كائن العرض الدلالي الموحد [EnumPresentation] المستخرج عبر [EnumPresentationRegistry].
class PosWalletHeroCard extends StatelessWidget {
  const PosWalletHeroCard({super.key, required this.wallet, this.onRefresh});

  final PosWalletEntity wallet;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final balanceFormatted = AmountFormatter.format(
      wallet.walletBalance.toStringAsFixed(2),
    );

    return Container(
      constraints: BoxConstraints(minHeight: 180.h),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: colors.executiveHeroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.28),
            blurRadius: 24.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. التوهج الضوئي الخلفي المحيطي
          Positioned(
            left: -AppSpacing.xxl,
            bottom: -AppSpacing.giant,
            child: IgnorePointer(
              child: Container(
                width: 170.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.secondary.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.secondary.withValues(alpha: 0.16),
                      blurRadius: AppSpacing.huge,
                      spreadRadius: AppSpacing.md,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. المحتوى القيادي الرئيسي
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرأس: المعرف وشارة المركز المحاسبي الموحدة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 18.r,
                        color: colors.executiveGoldIcon,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'محفظة نقطة البيع',
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.executiveGoldAccent,
                          fontWeight: AppTypography.medium,
                        ),
                      ),
                    ],
                  ),
                  CustomStatusBadge.fromPresentation(
                    wallet.accountingPresentation,
                    showDot: true,
                    isCompact: true,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),

              // كتلة الرصيد المالي المعتمد
              Text(
                'الرصيد المالي المتاح',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: AppTypography.regular,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    balanceFormatted,
                    style: AppTypography.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      wallet.currencyCode,
                      style: AppTypography.labelSmall.copyWith(
                        color: colors.executiveGoldAccent,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // 3. شريط مؤشر القدرة الائتمانية والشرائية
              PosWalletPurchasingPowerGauge(wallet: wallet),
            ],
          ),
        ],
      ),
    );
  }
}
