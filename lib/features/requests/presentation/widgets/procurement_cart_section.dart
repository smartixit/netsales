import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// عرض سلة بنود التوريد وإجراءات تعديل الكمية أو حذف الباقة.
class ProcurementCartSection extends GetView<PosProcurementController> {
  const ProcurementCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final lines = controller.procurementCart.toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'بنود طلب التوريد',
                style: AppTypography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${lines.length} باقة',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.vSm,
          if (lines.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  AppSpacing.hSm,
                  Expanded(
                    child: Text(
                      'لم تضف أي باقة بعد. اختر باقة وحدد كمية الأوراق ثم أضفها إلى الطلب.',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...lines.map((line) {
              final packageColor = CustomColorPicker.parseHex(line.package.packageColor);

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // الشريط اللوني الرقيق على حافة البطاقة
                          Container(
                            width: 5,
                            color: packageColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: packageColor.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
                                        ),
                                        child: Icon(
                                          Icons.wifi_tethering_rounded,
                                          color: packageColor,
                                        ),
                                      ),
                                      AppSpacing.hSm,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              line.package.packageName,
                                              style: AppTypography.bodyMedium.copyWith(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            AppSpacing.vXxs,
                                            Text(
                                              line.fullQuantityLabel,
                                              style: AppTypography.bodySmall.copyWith(
                                                color: colors.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            () {
                                              final quoteLine = controller.serverQuote.value
                                                  ?.findLine(line.package.packageId);
                                              if (quoteLine == null) {
                                                return const SizedBox.shrink();
                                              }

                                              final hasDiscount = quoteLine.discountRate > 0;
                                              return Padding(
                                                padding: EdgeInsets.only(top: AppSpacing.xs),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'السعر: ${AmountFormatter.formatValue(quoteLine.effectivePrice)} ر.ي',
                                                      style: AppTypography.labelSmall.copyWith(
                                                        color: colors.primary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (hasDiscount) ...[
                                                      AppSpacing.hXxs,
                                                      Text(
                                                        '(-${quoteLine.discountRate.toStringAsFixed(1)}%)',
                                                        style: AppTypography.labelSmall.copyWith(
                                                          color: colors.secondary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                    const Spacer(),
                                                    Text(
                                                      'المجموع: ${AmountFormatter.formatValue(quoteLine.lineNetTotal)} ر.ي',
                                                      style: AppTypography.labelSmall.copyWith(
                                                        color: colors.onSurface,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppSpacing.vSm,
                                  Divider(
                                    height: 1,
                                    color: colors.outlineVariant.withValues(alpha: 0.3),
                                  ),
                                  AppSpacing.vXs,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton.outline(
                                          text: 'تعديل الكمية',
                                          icon: Icons.edit_outlined,
                                          size: AppButtonSize.small,
                                          onPressed: () => controller.editCartLine(line),
                                        ),
                                      ),
                                      AppSpacing.hSm,
                                      CustomButton.icon(
                                        icon: Icons.delete_outline_rounded,
                                        tooltip: 'حذف ${line.package.packageName} من الطلب',
                                        size: AppButtonSize.small,
                                        foregroundColor: colors.error,
                                        backgroundColor: colors.error.withValues(
                                          alpha: 0.08,
                                        ),
                                        onPressed: () => controller.removeCartLine(
                                          line.package.packageId,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      );
    });
  }
}
