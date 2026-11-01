import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة الرصيد والسيولة المركزية للمحفظة (WalletBalanceHeroCard)
/// ============================================================================
/// تعرض الرصيد الرسمي المعتمد حصراً من الخادم المركزي بدقة مطلقة،
/// وتوفر خيار حجب الرصيد للخصوصية (Privacy Mask) وبيان الوضع المحاسبي النزيه.
class WalletBalanceHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double balance;
  final String currency;
  final bool isBalanceHidden;
  final VoidCallback onTogglePrivacy;
  final bool isPosDebt;
  final String? statusLabel;
  final String? accountUuid;
  final VoidCallback? onRefresh;

  const WalletBalanceHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.balance,
    this.currency = 'ر.ي',
    required this.isBalanceHidden,
    required this.onTogglePrivacy,
    this.isPosDebt = false,
    this.statusLabel,
    this.accountUuid,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayBalance = isPosDebt ? balance.abs() : balance;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: AppGradients.moreHero(context),
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.level2(context),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.28),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الترويسة والعنوان الفرعي وزر إخفاء الرصيد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Icon(
                        isPosDebt
                            ? Icons.account_balance_rounded
                            : Icons.account_balance_wallet_rounded,
                        color: isPosDebt ? colors.warning : colors.primary,
                        size: 20.r,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomInteractiveBounce(
                    onTap: onTogglePrivacy,
                    child: Container(
                      padding: EdgeInsets.all(7.r),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBalanceHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 18.r,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (onRefresh != null) ...[
                    AppSpacing.hXs,
                    CustomInteractiveBounce(
                      onTap: onRefresh,
                      child: Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 18.r,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          AppSpacing.vMd,

          // 2. قيمة الرصيد الرسمي مع العملة وحالة الخصوصية
          Text(
            isPosDebt ? 'المديونية الحالية المستحقة' : 'الرصيد الفعلي المتاح',
            style: AppTypography.labelSmall.copyWith(
              color: isPosDebt ? colors.warning : colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.vXs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isBalanceHidden
                    ? '••••••••'
                    : AmountFormatter.formatValue(displayBalance),
                style: AppTypography.headlineMedium.copyWith(
                  color: isPosDebt ? colors.error : colors.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: isBalanceHidden ? 2.0 : 0.0,
                ),
              ),
              AppSpacing.hXs,
              Text(
                currency,
                style: AppTypography.labelLarge.copyWith(
                  color: isPosDebt ? colors.error : colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          AppSpacing.vSm,

          // 3. شريط المؤشرات والحالة المحاسبية
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: (isPosDebt ? colors.warningContainer : colors.primaryContainer)
                      .withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPosDebt ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
                      size: 12.r,
                      color: isPosDebt ? colors.warning : colors.primary,
                    ),
                    AppSpacing.hXs,
                    Text(
                      statusLabel ?? (isPosDebt ? 'حساب جاري بمديونية' : 'رصيد دائن نشط'),
                      style: AppTypography.labelSmall.copyWith(
                        color: isPosDebt ? colors.warning : colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (accountUuid != null && accountUuid!.isNotEmpty)
                Text(
                  accountUuid!,
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),

          AppSpacing.vSm,
          const Divider(height: 1),
          AppSpacing.vSm,

          // 4. إشعار الأمان والتدقيق (قفل الطفرات المالية)
          Row(
            children: [
              Icon(
                Icons.lock_clock_rounded,
                size: 13.r,
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              AppSpacing.hXs,
              Expanded(
                child: Text(
                  'كشف الحساب للقراءة والتدقيق الرسمي؛ العمليات المالية مغلقة برمجياً.',
                  style: AppTypography.labelSmall.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.75),
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

