import 'package:flutter/material.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/catalog/domain/entities/effective_package_discount_entity.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';

/// بطاقة عرض وتفسير الخصم الفعلي والسعر المعتمد من الخادم لنقطة البيع (Server-Authoritative Pricing §34)
class ProcurementPricingDiscountCard extends StatelessWidget {
  final PackageEntity package;
  final EffectivePackageDiscountEntity? discount;
  final bool isLoading;
  final String? errorMessage;
  final SaleType saleType;

  const ProcurementPricingDiscountCard({
    super.key,
    required this.package,
    this.discount,
    this.isLoading = false,
    this.errorMessage,
    required this.saleType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
            ),
            AppSpacing.hSm,
            Expanded(
              child: Text(
                'جاري جلب السعر والخصم الفعلي المعتمد لنقطتك من الخادم...',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: colors.error, size: 20),
            AppSpacing.hSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تعذر جلب الخصم المخصص لنقطة البيع',
                    style: AppTypography.labelMedium.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Text(
                    'سيتم احتساب واعتماد الأسعار النهائية سيادياً لدى الخادم عند إرسال الطلب.',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (discount == null) {
      return const SizedBox.shrink();
    }

    final isCash = saleType == SaleType.cash;
    final effectivePrice = isCash
        ? discount!.effectiveCashPrice
        : discount!.effectiveCreditPrice;
    final discountRate = isCash
        ? discount!.discountCash
        : discount!.discountCredit;
    final savings = isCash
        ? discount!.cashSavings
        : discount!.creditSavings;
    final isCustom = discount!.isCustom;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCustom
            ? colors.primary.withValues(alpha: 0.05)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isCustom
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCustom ? Icons.verified_outlined : Icons.sell_outlined,
                color: isCustom ? colors.primary : colors.onSurfaceVariant,
                size: 20,
              ),
              AppSpacing.hXs,
              Text(
                'التسعير المعتمد من الخادم',
                style: AppTypography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              CustomStatusBadge(
                label: isCustom ? 'خصم مخصص لنقطتك' : 'الخصم الافتراضي للباقة',
                tone: isCustom ? SemanticTone.success : SemanticTone.neutral,
              ),
            ],
          ),
          AppSpacing.vSm,
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
          AppSpacing.vSm,

          // الأسعار والوفورات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السعر الفعلي للكرت الواحد (${isCash ? 'نقداً' : 'آجلاً'}):',
                    style: AppTypography.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.vXxs,
                  Row(
                    children: [
                      Text(
                        AmountFormatter.formatValue(effectivePrice),
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (discountRate > 0) ...[
                        AppSpacing.hSm,
                        Text(
                          AmountFormatter.formatValue(discount!.originalPackagePrice),
                          style: AppTypography.bodySmall.copyWith(
                            color: colors.onSurfaceVariant,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (discountRate > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'خصم $discountRate%',
                        style: AppTypography.labelMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'وفر ${AmountFormatter.formatValue(savings)} لكل كرت',
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
