import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_elevation.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/more/domain/entities/more_wallet_entity.dart';
import 'package:netsales/features/more/presentation/controllers/more_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/interactions/custom_interactive_bounce.dart';

/// ============================================================================
/// بطاقة محفظة الحساب المالية التنفيذية (MoreWalletCard)
/// ============================================================================
/// بطاقة مالية متقدمة بأسلوب Fintech Glass، تبرز الرصيد اللحظي،
/// وتدعم حماية الخصوصية عبر إخفاء الرصيد (Privacy Toggle)، وبيان المديونية.
class MoreWalletCard extends StatelessWidget {
  final MoreWalletEntity? wallet;
  final MoreController controller;

  const MoreWalletCard({
    super.key,
    required this.wallet,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final balance = wallet?.balance ?? 0.0;
    final isOverdrawn = wallet?.isOverdrawn ?? false;

    return Container(
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
          // 1. الترويسة وشارات الأمان وإخفاء الرصيد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.25),
                          width: 0.8.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: colors.primary,
                        size: 19.r,
                      ),
                    ),
                    AppSpacing.hSm,
                    Expanded(
                      child: Text(
                        'رصيد المحفظة التشغيلية',
                        maxLines: 1,
                        style: AppTypography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // أدوات الأمان والخصوصية
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شارة حالة أمان المحفظة
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdrawn
                          ? colors.warningContainer
                          : colors.successContainer,
                      borderRadius: AppRadius.fullRadius,
                      border: Border.all(
                        color: (isOverdrawn ? colors.warning : colors.success)
                            .withValues(alpha: 0.3),
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOverdrawn
                              ? Icons.warning_amber_rounded
                              : Icons.verified_rounded,
                          size: 11.r,
                          color: isOverdrawn ? colors.warning : colors.success,
                        ),
                        AppSpacing.hXxs,
                        Text(
                          isOverdrawn ? 'رصيد مكشوف' : 'محفظة مؤمنة',
                          style: AppTypography.labelSmall.copyWith(
                            color: isOverdrawn
                                ? colors.warning
                                : colors.success,
                            fontWeight: FontWeight.w800,
                            fontSize: 9.5.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpacing.vMd,

          // 2. الرصيد المالي المنسق بخط Hero مع دعم وضع الخصوصية
          Obx(
            () => Row(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      controller.isBalanceHidden.value
                          ? '••••••••'
                          : AmountFormatter.formatValue(balance),
                      style: AppTypography.currencyHero.copyWith(
                        color: isOverdrawn ? colors.error : colors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 26.sp,
                      ),
                    ),
                    AppSpacing.hXs,
                    Text(
                      wallet?.currency ?? 'ر.ي',
                      style: AppTypography.currencySymbol.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                AppSpacing.hSm,

                // زر إخفاء وإظهار الرصيد لحماية الخصوصية
                Obx(
                  () => CustomInteractiveBounce(
                    onTap: controller.toggleBalanceVisibility,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.25),
                          width: 0.6.w,
                        ),
                      ),
                      child: Icon(
                        controller.isBalanceHidden.value
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 16.r,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. تنبيه المديونية المستحقة إن وجدت
          if (wallet != null && wallet!.debitAmount > 0) ...[
            AppSpacing.vXs,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.warningContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadius.xs),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.3),
                  width: 0.8.w,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13.r,
                    color: colors.warning,
                  ),
                  AppSpacing.hXs,
                  Text(
                    'المديونية المستحقة: ${AmountFormatter.formatValue(wallet!.debitAmount)} ${wallet!.currency}',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          AppSpacing.vMd,

          // 4. أزرار العمليات السريعة للمحفظة
          Row(
            children: [
              Expanded(
                child: CustomButton.primary(
                  text: 'شحن وتغذية المحفظة',
                  icon: Icons.add_circle_outline_rounded,
                  height: 38.h,
                  onPressed: () {
                    // فتح حوار تغذية المحفظة أو الحسابات
                  },
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: CustomButton.outline(
                  text: 'سجل الحركات المالية',
                  icon: Icons.history_rounded,
                  height: 38.h,
                  onPressed: () {
                    // فتح سجل العمليات
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
