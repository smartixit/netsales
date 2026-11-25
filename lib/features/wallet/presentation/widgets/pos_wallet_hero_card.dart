import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/pos_wallet_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// الملخص المالي الرئيسي لحساب نقطة البيع.
class PosWalletHeroCard extends StatelessWidget {
  const PosWalletHeroCard({super.key, required this.wallet, this.onRefresh});

  final PosWalletEntity wallet;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accountingPresentation =
        EnumPresentationRegistry.resolveAccountingStatus(
      wallet.typedAccountingStatus,
      serverLabel: wallet.accountingStatusLabel,
    );
    final balanceFormatted = AmountFormatter.format(
      wallet.walletBalance.toStringAsFixed(2),
    );
    final openingBalanceFormatted = AmountFormatter.format(
      wallet.openingBalance.toStringAsFixed(2),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.045),
            blurRadius: 22.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: colors.primary,
                  size: 21.r,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.posName?.trim().isNotEmpty == true
                          ? wallet.posName!
                          : 'حساب نقطة البيع',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: AppTypography.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      wallet.networkName?.trim().isNotEmpty == true
                          ? 'ضمن شبكة ${wallet.networkName}'
                          : 'الحساب التشغيلي لنقطة البيع',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomStatusBadge(
                    label: wallet.status ? 'الحساب نشط' : 'الحساب موقوف',
                    tone: wallet.status ? SemanticTone.success : SemanticTone.danger,
                    isCompact: true,
                    showDot: true,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  CustomStatusBadge.fromPresentation(
                    accountingPresentation,
                    isCompact: true,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'الرصيد الحالي',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: AppTypography.medium,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    balanceFormatted,
                    maxLines: 1,
                    style: AppTypography.displaySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: AppTypography.bold,
                      letterSpacing: -0.6,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                wallet.currencyCode,
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 16.r,
                color: colors.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'الرصيد الافتتاحي',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '$openingBalanceFormatted ${wallet.currencyCode}',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: AppTypography.semiBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
