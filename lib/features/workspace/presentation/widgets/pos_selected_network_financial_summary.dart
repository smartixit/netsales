import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/finance/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_card.dart';

class PosSelectedNetworkFinancialSummary extends StatelessWidget {
  const PosSelectedNetworkFinancialSummary({
    super.key,
    required this.networkName,
    required this.wallet,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onOpenAccount,
  });

  final String networkName;
  final PosWalletEntity? wallet;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onOpenAccount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (isLoading) {
      return const CustomSkeletonCard(height: 166);
    }
    if (error != null) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: colors.error),
            AppSpacing.hSm,
            Expanded(
              child: Text(
                'تعذر تحميل الحساب المالي لشبكة $networkName',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            CustomButton.text(text: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      );
    }
    if (wallet == null) {
      return const SizedBox.shrink();
    }

    final valueColor = wallet!.isOverdrawn ? colors.error : colors.primary;
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملخص حسابك',
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      networkName,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.account_balance_wallet_rounded,
                color: colors.primary,
                size: 24.r,
              ),
            ],
          ),
          AppSpacing.vLg,
          Text(
            'رصيد المحفظة',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            AmountFormatter.format(wallet!.walletBalance.toString()),
            style: AppTypography.headlineMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vMd,
          Divider(color: colors.outlineVariant.withValues(alpha: 0.45)),
          AppSpacing.vSm,
          Row(
            children: [
              Expanded(
                child: _FinancialValue(
                  label: 'السقف الائتماني',
                  value: wallet!.creditLimit == null
                      ? 'بدون تسهيلات'
                      : AmountFormatter.format(wallet!.creditLimit.toString()),
                ),
              ),
              Expanded(
                child: _FinancialValue(
                  label: 'المتاح من الائتمان',
                  value: AmountFormatter.format(
                    wallet!.availableOverdraftCapacity.toString(),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vMd,
          SizedBox(
            width: double.infinity,
            child: CustomButton.outline(
              text: 'كشف الحساب والحركات',
              prefix: Icons.receipt_long_rounded,
              onPressed: onOpenAccount,
              height: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialValue extends StatelessWidget {
  const _FinancialValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
