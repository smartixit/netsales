import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/semantic_tone.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/badges/custom_status_badge.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

/// بطاقة عرض وتلخيص الحساب المالي الرسمي المعتمد من الخادم لطلب التوريد (Server-Authoritative Quote Card)
class ProcurementFinancialQuoteCard extends GetView<PosProcurementController> {
  const ProcurementFinancialQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      // إذا كانت السلة فارغة تماماً، لا نعرض بطاقة التسعير
      if (controller.procurementCart.isEmpty) {
        return const SizedBox.shrink();
      }

      // 1. حالة جلب الأسعار والخصومات من الخادم
      if (controller.isLoadingQuote.value) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              AppSpacing.hSm,
              Expanded(
                child: Text(
                  'جاري احتساب السعر والخصم الفعليين المعتمدين...',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      // 2. حالة تعذر جلب عرض الأسعار
      final error = controller.quoteError.value;
      if (error != null && error.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.error.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: colors.error, size: 20),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'تعذر الحصول على عرض الأسعار المعتمد',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.vXs,
              Text(
                error,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              AppSpacing.vSm,
              CustomButton.outline(
                text: 'إعادة احتساب الأسعار',
                icon: Icons.refresh_rounded,
                size: AppButtonSize.small,
                onPressed: controller.fetchServerQuote,
              ),
            ],
          ),
        );
      }

      // 3. عرض التسعير الرسمي المعتمد
      final quote = controller.serverQuote.value;
      if (quote == null) {
        return const SizedBox.shrink();
      }

      final hasDiscount = quote.discountTotal > 0;

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ترويسة البطاقة المالية
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: colors.primary,
                    size: 18,
                  ),
                  AppSpacing.hXs,
                  Expanded(
                    child: Text(
                      'عرض الأسعار المعتمد',
                      style: AppTypography.titleSmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AppSpacing.hSm,
                  CustomStatusBadge(
                    label: quote.saleTypeLabel,
                    tone: quote.saleType == SaleType.cash
                        ? SemanticTone.success
                        : SemanticTone.info,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // المجموع الأساسي قبل الخصم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'المجموع الأساسي:',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '${AmountFormatter.formatValue(quote.grossTotal)} ${quote.currency}',
                        style: AppTypography.bodyLarge.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // إجمالي الخصم الفعلي إن وُجد
                  if (hasDiscount) ...[
                    AppSpacing.vSm,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: AppSpacing.xs,
                            children: [
                              Text(
                                'إجمالي الخصم المعتمد:',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              CustomStatusBadge(
                                label:
                                    'وفر ${quote.totalDiscountPercentage.toStringAsFixed(1)}%',
                                tone: SemanticTone.success,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '- ${AmountFormatter.formatValue(quote.discountTotal)} ${quote.currency}',
                          style: AppTypography.bodyLarge.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],

                  AppSpacing.vSm,
                  Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.35),
                  ),
                  AppSpacing.vSm,

                  // الإجمالي النهائي المستحق
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإجمالي النهائي المستحق:',
                              style: AppTypography.titleSmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.vXxs,
                            Text(
                              'المبلغ المعتمد للتسوية المالية',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.hSm,
                      Text(
                        '${AmountFormatter.formatValue(quote.netTotal)} ${quote.currency}',
                        style: AppTypography.titleLarge.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
