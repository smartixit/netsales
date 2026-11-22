import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/presentation/enums/enum_presentation.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_gradients.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/wallet/domain/entities/network_wallet_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة خزينة مزود الشبكة التنفيذية (Network Wallet Hero Card)
///
/// مصممة للمراقبة المالية والحوكمة بدون أي أزرار تعديل أو حذف يدوي.
class NetworkWalletHeroCard extends StatelessWidget {
  const NetworkWalletHeroCard({
    super.key,
    required this.wallet,
    this.onRefresh,
    this.onExportStatement,
  });

  final NetworkWalletEntity wallet;
  final VoidCallback? onRefresh;
  final VoidCallback? onExportStatement;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final balanceFormatted = AmountFormatter.format(
      wallet.walletBalance.toStringAsFixed(2),
    );

    const statusPresentation = EnumPresentation(
      label: 'خزينة نشطة',
      tone: SemanticTone.success,
      icon: Icons.verified_user_rounded,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppGradients.entitySapphire(context)
            : LinearGradient(
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.95),
                  colors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 16.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. ترويسة البطاقة: اسم الشبكة + شارة الحالة + زر التحديث
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: colors.primary,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.networkName ?? 'محفظة الخزينة المركزية',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'دفتر أستاذ سيادي غير قابل للتعديل اليدوي',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onRefresh != null)
                  CustomButton.icon(
                    icon: Icons.refresh_rounded,
                    onPressed: onRefresh,
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // 2. الرصيد التشغيلي المتاح وشارة الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرصيد التشغيلي المتاح',
                      style: AppTypography.labelMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          balanceFormatted,
                          style: AppTypography.headlineMedium.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          wallet.currencyCode,
                          style: AppTypography.titleSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomStatusBadge.fromPresentation(statusPresentation),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // 3. شريط التدقيق والأمان المؤسسي
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16.sp,
                    color: colors.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'الحركات مرتبطة آلياً بفواتير المبيعات والتغذية وسندات الصرف المعتمدة',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  if (onExportStatement != null) ...[
                    SizedBox(width: AppSpacing.xs),
                    CustomButton.secondary(
                      text: 'تصدير PDF',
                      icon: Icons.picture_as_pdf_outlined,
                      onPressed: onExportStatement,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
