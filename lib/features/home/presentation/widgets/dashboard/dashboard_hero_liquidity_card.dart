import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/home/domain/entities/dashboard_overview_entity.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// ============================================================================
/// بطاقة السيولة المالية المركزية (DashboardHeroLiquidityCard)
/// ============================================================================
/// تبرز الرصيد الفعلي للمحفظة والمركز المالي (مدين / دائن) بتصميم مصرفي فخم.
class DashboardHeroLiquidityCard extends StatelessWidget {
  final DashboardLiquidityEntity liquidity;
  final VoidCallback? onActionTap;

  const DashboardHeroLiquidityCard({
    super.key,
    required this.liquidity,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isNegative = liquidity.balance < 0 || liquidity.isOverdrawn;
    final formattedBalance = AmountFormatter.formatValue(liquidity.balance.abs());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isNegative
            ? LinearGradient(
                colors: [colors.error, colors.error.withValues(alpha: 0.8)],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              )
            : AppGradients.financialHero(context),
        borderRadius: AppRadius.xlRadius,
        boxShadow: isNegative
            ? AppElevation.tinted(context, colors.error)
            : AppElevation.tinted(context, colors.primary),
      ),
      child: Stack(
        children: [
          // خلفية زخرفية ناعمة
          PositionedDirectional(
            end: -20.r,
            top: -20.r,
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 140.r,
              color: colors.onPrimary.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // سطر الحالة ونوع الرصيد
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18.r,
                            color: colors.onPrimary.withValues(alpha: 0.9),
                          ),
                          AppSpacing.hSm,
                          Expanded(
                            child: Text(
                              isNegative
                                  ? 'الرصيد المدين (مستحق السداد)'
                                  : 'الرصيد المالي المتاح',
                              style: AppTypography.labelMedium.copyWith(
                                color: colors.onPrimary.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.hSm,
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.onPrimary.withValues(alpha: 0.2),
                        borderRadius: AppRadius.fullRadius,
                      ),
                      child: Text(
                        isNegative ? 'حساب مدين' : 'نشط ومعتمد',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpacing.vMd,

                // الرقم المالي البارز
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (isNegative)
                        Text(
                          '- ',
                          style: AppTypography.headlineSmall.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      Text(
                        formattedBalance,
                        style: AppTypography.headlineSmall.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      AppSpacing.hSm,
                      Text(
                        liquidity.currency,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.vMd,

                // زر الإجراء السريع (تسوية / تغذية المحفظة)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: CustomButton.secondary(
                    text: isNegative ? 'تسوية الحساب الآن' : 'سجل حركة المحفظة',
                    icon: isNegative ? Icons.payment_rounded : Icons.history_rounded,
                    onPressed: onActionTap,
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
