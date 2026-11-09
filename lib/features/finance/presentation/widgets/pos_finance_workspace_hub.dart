import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/routing/app_routes.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// مركز دخول المحفظة والذمم لمساحة عمل نقطة البيع.
/// يعرض مسارات الخدمة فقط ويترك الأرصدة والحسابات للخادم.
class PosFinanceWorkspaceHub extends StatelessWidget {
  const PosFinanceWorkspaceHub({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: colors.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.onSecondaryContainer,
                    size: 28,
                  ),
                ),
                AppSpacing.hMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المحفظة والالتزامات',
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      AppSpacing.vXs,
                      Text(
                        'تابع رصيدك الائتماني والذمم المستحقة وفواتير البيع الآجل ضمن نطاق الشبكة.',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSecondaryContainer.withValues(
                            alpha: 0.86,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vXl,
          Text(
            'إدارة الحساب',
            style: AppTypography.titleMedium.copyWith(color: colors.onSurface),
          ),
          AppSpacing.vXs,
          Text(
            'اختر كشف الحساب أو راجع الذمم والفواتير غير المسددة.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vLg,
          SizedBox(
            width: double.infinity,
            child: CustomButton.primary(
              text: 'كشف الذمم والفواتير المستحقة',
              prefix: Icons.receipt_long_rounded,
              size: AppButtonSize.large,
              width: double.infinity,
              onPressed: () => Get.toNamed<void>(AppRoutes.posDebtLedger),
            ),
          ),
          AppSpacing.vMd,
          SizedBox(
            width: double.infinity,
            child: CustomButton.outline(
              text: 'كشف المحفظة والائتمان',
              prefix: Icons.account_balance_wallet_outlined,
              foregroundColor: colors.onSurface,
              borderColor: colors.outlineVariant,
              width: double.infinity,
              height: 64,
              onPressed: () => Get.toNamed<void>(AppRoutes.posWalletStatement),
            ),
          ),
        ],
      ),
    );
  }
}
