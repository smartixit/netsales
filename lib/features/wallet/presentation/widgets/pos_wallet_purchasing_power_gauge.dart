import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';

/// يعرض حدود التسهيل والقدرة الشرائية كما احتسبها الخادم.
class PosWalletPurchasingPowerGauge extends StatelessWidget {
  const PosWalletPurchasingPowerGauge({super.key, required this.wallet});

  final PosWalletEntity wallet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasFacility = wallet.hasCreditFacility;
    final creditLimitFormatted = hasFacility
        ? AmountFormatter.format(wallet.creditLimit!.toStringAsFixed(2))
        : 'غير معتمد';
    final availableFormatted = hasFacility
        ? AmountFormatter.format(
            wallet.availableOverdraftCapacity.toStringAsFixed(2),
          )
        : '—';
    final purchasingPowerFormatted = AmountFormatter.format(
      wallet.totalPurchasingPower.toStringAsFixed(2),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التسهيل والقدرة الشرائية',
            style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: AppTypography.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            'قيم معتمدة من النظام المالي',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WalletMetric(
                  label: 'السقف الائتماني',
                  value: creditLimitFormatted,
                  currency: hasFacility ? wallet.currencyCode : null,
                  valueColor: colors.onSurface,
                ),
              ),
              Container(
                width: 1,
                height: 42.h,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _WalletMetric(
                  label: 'المتاح من التسهيل',
                  value: availableFormatted,
                  currency: hasFacility ? wallet.currencyCode : null,
                  valueColor: colors.primary,
                ),
              ),
              Container(
                width: 1,
                height: 42.h,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _WalletMetric(
                  label: 'القدرة الشرائية',
                  value: purchasingPowerFormatted,
                  currency: wallet.currencyCode,
                  valueColor: colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletMetric extends StatelessWidget {
  const _WalletMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    this.currency,
  });

  final String label;
  final String value;
  final String? currency;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleSmall.copyWith(
            color: valueColor,
            fontWeight: AppTypography.bold,
          ),
        ),
        if (currency != null) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            currency!,
            maxLines: 1,
            style: AppTypography.labelSmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
