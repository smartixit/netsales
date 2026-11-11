import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

class PosDualWalletCard extends StatelessWidget {
  final PosWalletEntity wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const PosDualWalletCard({
    super.key,
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return CustomInteractiveBounce(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.05)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? AppElevation.level2(context)
              : AppElevation.level1(context),
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
                      Icons.account_balance_wallet_outlined,
                      color: isSelected
                          ? colors.primary
                          : colors.onSurfaceVariant,
                      size: 22,
                    ),
                    AppSpacing.hSm,
                    Text(
                      wallet.networkName ?? 'شبكة #${wallet.networkId}',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CustomStatusBadge(
                  label: wallet.status ? 'نشطة' : 'مجمدة',
                  tone: wallet.status
                      ? SemanticTone.success
                      : SemanticTone.danger,
                ),
              ],
            ),
            AppSpacing.vSm,
            Divider(color: colors.outlineVariant.withValues(alpha: 0.3)),
            AppSpacing.vSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد النقدي الفعلي',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      AmountFormatter.format(wallet.walletBalance.toString()),
                      style: AppTypography.titleLarge.copyWith(
                        color: wallet.walletBalance >= 0
                            ? colors.primary
                            : colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'السقف الائتماني',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.vXs,
                    Text(
                      wallet.creditLimit != null
                          ? AmountFormatter.format(
                              wallet.creditLimit.toString(),
                            )
                          : 'بدون تسهيلات',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (wallet.creditLimit != null && wallet.totalPurchasingPower != null) ...[
              AppSpacing.vSm,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'القدرة الشرائية المتاحة (نقدي + ائتمان):',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      AmountFormatter.format(
                        wallet.totalPurchasingPower!.toString(),
                      ),
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
