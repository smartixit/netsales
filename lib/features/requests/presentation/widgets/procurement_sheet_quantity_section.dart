import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/voucher_sheet_calculator.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/custom_text_field.dart';

/// واجهة كمية التوريد بوحدة الأوراق مع عرض تحويلها إلى voucher_count.
class ProcurementSheetQuantitySection
    extends GetView<PosProcurementController> {
  const ProcurementSheetQuantitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كمية التوريد',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Text(
          'أدخل عدد الأوراق أو جزءاً منها؛ ويمكنك كتابة أي كمية غير موجودة في الاختصارات.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        CustomTextField(
          controller: controller.quantityController,
          label: 'عدد الأوراق',
          hint: 'مثال: 1 أو 1.5 أو 12',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: const Icon(Icons.layers_outlined),
          validator: controller.validateSheetQuantity,
        ),
        AppSpacing.vSm,
        Obx(() {
          final package = controller.selectedPackage.value;
          final presets = VoucherSheetCalculator.getPresets(
            package?.packageVoucherCount ?? 0,
          );

          if (presets.isEmpty) {
            return const SizedBox.shrink();
          }

          final enteredSheets =
              double.tryParse(controller.quantityInput.value.trim()) ?? -1;

          return Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: presets.map((preset) {
              final isSelected =
                  (enteredSheets - preset.sheets).abs() < 1e-9;

              if (isSelected) {
                return CustomButton.secondary(
                  text: preset.shortLabel,
                  size: AppButtonSize.small,
                  onPressed: () =>
                      controller.setSheetCount(preset.sheets.toString()),
                );
              }

              return CustomButton.outline(
                text: preset.shortLabel,
                size: AppButtonSize.small,
                onPressed: () =>
                    controller.setSheetCount(preset.sheets.toString()),
              );
            }).toList(growable: false),
          );
        }),
        AppSpacing.vSm,
        Obx(() {
          final package = controller.selectedPackage.value;
          if (package == null) {
            return Text(
              'اختر الباقة لعرض عدد الكروت المكافئ لسعة الورقة.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            );
          }

          final voucherCount = controller.requestedVoucherCount;
          final quantityText = controller.quantityInput.value.trim();
          if (voucherCount <= 0) {
            return Text(
              'أدخل كمية أوراق صحيحة لعرض عدد الكروت المكافئ.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.error,
              ),
            );
          }

          final breakdown = VoucherSheetCalculator.describe(
            voucherCount,
            package.packageVoucherCount,
          );

          return Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.fact_check_outlined,
                  color: colors.primary,
                  size: AppSpacing.lg,
                ),
                AppSpacing.hSm,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكمية التي سترسل إلى النظام',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        '$voucherCount كرت',
                        style: AppTypography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        '$quantityText ورقة · $breakdown',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'سعة الورقة لهذه الباقة: ' +
                            package.packageVoucherCount.toString() +
                            ' كرت',
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
        }),
      ],
    );
  }
}
