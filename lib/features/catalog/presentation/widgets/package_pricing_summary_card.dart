import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/indicators/custom_interactive_amount_text.dart';

/// بطاقة عرض الهيكل المالي والتسعيري والخصومات للباقة (Server-Authoritative Values §34)
class PackagePricingSummaryCard extends StatelessWidget {
  final PackageEntity package;

  const PackagePricingSummaryCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: AppSpacing.xl,
                color: colors.primary,
              ),
              AppSpacing.hXs,
              Text(
                'التعرفة المالية والأسعار الافتراضية',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          AppSpacing.vSm,

          // السعر الأساسي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر الأساسي للكارت (Base Price)',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              CustomInteractiveAmountText(
                amount: package.packageVoucherPrice,
                style: AppTypography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          AppSpacing.vMd,

          // تفصيل الخصم النقدي والآجل في عمودين
          Row(
            children: [
              // قسم الدفع النقدي
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: AppSpacing.lg,
                            color: colors.success,
                          ),
                          AppSpacing.hXs,
                          Text(
                            'السعر النقدي',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXs,
                      Text(
                        'الخصم: ${package.packageDefaultCashDiscount}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'قيمة الخصم: ${AmountFormatter.format(package.cashDiscountAmount.toString())}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vSm,
                      Text(
                        AmountFormatter.format(
                          package.effectiveCashPrice.toString(),
                        ),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AppSpacing.hSm,

              // قسم الدفع الآجل
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.secondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card_outlined,
                            size: AppSpacing.lg,
                            color: colors.secondary,
                          ),
                          AppSpacing.hXs,
                          Text(
                            'السعر الآجل',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vXs,
                      Text(
                        'الخصم: ${package.packageDefaultCreditDiscount}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'قيمة الخصم: ${AmountFormatter.format(package.creditDiscountAmount.toString())}',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vSm,
                      Text(
                        AmountFormatter.format(
                          package.effectiveCreditPrice.toString(),
                        ),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
