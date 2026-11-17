import 'package:flutter/material.dart';
import 'package:netsales/widgets/feedback/custom_state_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/workspace/presentation/models/pos_wallet_summary_view_model.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/indicators/custom_pulsing_indicator.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// كرت ملخص الحساب المالي لنقطة البيع لدى الشبكة المحددة (PosSelectedNetworkFinancialSummary)
/// متطابق هندسياً ومعمارياً مع ExecutiveLiquidityCard بنمط زجاجي كربوني فاخر يمنع التزاحم
class PosSelectedNetworkFinancialSummary extends StatelessWidget {
  const PosSelectedNetworkFinancialSummary({
    super.key,
    required this.networkName,
    required this.summary,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.onOpenAccount,
  });

  final String networkName;
  final PosWalletSummaryViewModel? summary;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onOpenAccount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const CustomStateView.loading(
        presentation: CustomStatePresentation.skeletonOnly,
        skeleton: CustomStateSkeleton(
          layout: CustomStateSkeletonLayout.cards,
          itemCount: 1,
          cardHeight: 190,
          maxColumns: 1,
          minItemWidth: 180,
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
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

    final walletSummary = summary;
    if (walletSummary == null) {
      return const SizedBox.shrink();
    }

    final isOverdrawn = walletSummary.isOverdrawn;
    final balanceColor = isOverdrawn
        ? const Color(0xFFF87171)
        : const Color(0xFF34D399);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF131D2A),
                  const Color(0xFF0F1722),
                  const Color(0xFF0B1019),
                ]
              : [
                  const Color(0xFF0F1E2A),
                  const Color(0xFF132433),
                  const Color(0xFF0C1722),
                ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. رأس الكرت: أيقونة وهوية الشبكة + شارة حالة الحساب
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 15.r,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ملخص حسابك لدى الشبكة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            networkName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.5.h),
                decoration: BoxDecoration(
                  color: isOverdrawn
                      ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                      : const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isOverdrawn
                        ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                        : const Color(0xFF10B981).withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPulsingIndicator(
                      color: isOverdrawn
                          ? const Color(0xFFF87171)
                          : const Color(0xFF34D399),
                      size: 4.r,
                      enablePing: true,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      isOverdrawn ? 'تجاوز السقف' : 'محفظة نشطة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 2. الرصيد الرئيسي للمحفظة
          Text(
            'رصيد المحفظة المالي',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11.5.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                walletSummary.formattedBalance,
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'ر.ي',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // 3. شبكة تفاصيل الائتمان والمتاح
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'السقف الائتماني',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10.5.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        walletSummary.creditLimitLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 28.h,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المتاح من الائتمان',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 10.5.sp,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        walletSummary.availableOverdraftLabel,
                        style: TextStyle(
                          color: const Color(0xFF38BDF8),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.vMd,

          // 4. زر كشف الحساب القياسي الفاخر
          CustomInteractiveBounce(
            onTap: onOpenAccount,
            child: Container(
              height: 42.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 16.r,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'كشف الحساب والحركات التفصيلية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 16.r,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
