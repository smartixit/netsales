import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// بطاقة محفظة الحساب المالية (MoreWalletCard)
/// ============================================================================
/// بطاقة مالية تفاعلية بأسلوب Bento Grid تعرض الرصيد اللحظي والمديونية وأزرار العمليات.
class MoreWalletCard extends StatelessWidget {
  final MoreWalletEntity? wallet;

  const MoreWalletCard({
    super.key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final balance = wallet?.balance ?? 0.0;
    final isOverdrawn = wallet?.isOverdrawn ?? false;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppElevation.level2(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.35),
          width: 1.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الترويسة وشارة أمان المحفظة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: colors.primary,
                      size: 20.r,
                    ),
                  ),
                  AppSpacing.hSm,
                  Text(
                    'رصيد المحفظة التشغيلية',
                    style: AppTypography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isOverdrawn
                      ? colors.warningContainer
                      : colors.successContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverdrawn ? Icons.warning_amber_rounded : Icons.lock_outline,
                      size: 12.r,
                      color: isOverdrawn ? colors.warning : colors.success,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isOverdrawn ? 'رصيد مكشوف' : 'محفظة مؤمنة',
                      style: AppTypography.labelSmall.copyWith(
                        color: isOverdrawn ? colors.warning : colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 2. الرصيد المالي المنسق
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                AmountFormatter.formatValue(balance),
                style: AppTypography.currencyHero.copyWith(
                  color: isOverdrawn ? colors.error : colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                wallet?.currency ?? 'ر.ي',
                style: AppTypography.currencySymbol.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // 3. تنبيه المديونية إن وجدت
          if (wallet != null && wallet!.debitAmount > 0) ...[
            AppSpacing.vXs,
            Text(
              'المديونية المستحقة: ${AmountFormatter.formatValue(wallet!.debitAmount)} ${wallet!.currency}',
              style: AppTypography.bodySmall.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],

          AppSpacing.vMd,

          // 4. أزرار العمليات السريعة للمحفظة
          Row(
            children: [
              Expanded(
                child: CustomButton.primary(
                  text: 'شحن المحفظة',
                  icon: Icons.add_circle_outline,
                  height: 38.h,
                  onPressed: () {},
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.outline(
                  text: 'سجل الحركات',
                  icon: Icons.history_rounded,
                  height: 38.h,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
