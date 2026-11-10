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

/// واجهة إدخال كمية التوريد بعدد الكروت المباشر مع دعم:
/// - الإدخال التراكمي السريع (Additive Presets)
/// - أزرار زيادة وإنقاص ورقة كاملة مع الحماية من السالب
/// - التصفير الفوري
class ProcurementSheetQuantitySection
    extends GetView<PosProcurementController> {
  const ProcurementSheetQuantitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'كمية الكروت المطلوبة',
              style: AppTypography.titleSmall.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              final count = controller.requestedVoucherCount;
              if (count <= 0) return const SizedBox.shrink();
              return GestureDetector(
                onTap: controller.clearVoucherQuantity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    'مسح الكمية',
                    style: AppTypography.labelSmall.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        AppSpacing.vXs,
        Text(
          'أدخل عدد الكروت المطلوبة مباشرة، أو اضغط على الكبسولات والأزرار للإضافة التراكمية السريعة.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,

        // حقل الإدخال مع أزرار التحكم الدقيق (+ ورقة / - ورقة)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // زر إنقاص ورقة كاملة
            Obx(() {
              final count = controller.requestedVoucherCount;
              final canDecrement = count > 0;

              return SizedBox(
                height: 48,
                child: CustomButton.outline(
                  text: '- ورقة',
                  size: AppButtonSize.small,
                  icon: Icons.remove_rounded,
                  onPressed: canDecrement ? controller.stepDownSheet : null,
                ),
              );
            }),
            AppSpacing.hSm,

            // حقل إدخال الكروت المباشر
            Expanded(
              child: CustomTextField(
                controller: controller.quantityController,
                label: 'عدد الكروت',
                hint: 'مثال: 51 أو 102 أو 500',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.style_outlined),
                validator: controller.validateVoucherQuantity,
              ),
            ),
            AppSpacing.hSm,

            // زر زيادة ورقة كاملة
            SizedBox(
              height: 48,
              child: CustomButton.outline(
                text: '+ ورقة',
                size: AppButtonSize.small,
                icon: Icons.add_rounded,
                onPressed: controller.stepUpSheet,
              ),
            ),
          ],
        ),
        AppSpacing.vSm,

        // كبسولات الإضافة التراكمية السريعة (+ كروت / + أوراق)
        Obx(() {
          final package = controller.selectedPackage.value;
          final sheetSize = package?.packageVoucherCount ?? 0;
          final presets = VoucherSheetCalculator.getPresets(sheetSize);

          if (presets.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إضافة سريعة تراكمية (انقر للإضافة إلى الإجمالي):',
                style: AppTypography.labelSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.vXs,
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: presets.map((preset) {
                  return CustomButton.outline(
                    text: '+ ${preset.shortLabel} (${preset.cards})',
                    size: AppButtonSize.small,
                    onPressed: () => controller.addVoucherQuantity(preset.cards),
                  );
                }).toList(growable: false),
              ),
            ],
          );
        }),
        AppSpacing.vSm,

        // بطاقة توضيحية لعدد الكروت وما يقابلها من أوراق
        Obx(() {
          final package = controller.selectedPackage.value;
          if (package == null) {
            return Text(
              'اختر الباقة لعرض تفكيك الكروت وسعة الورقة.',
              style: AppTypography.bodySmall.copyWith(
                color: colors.onSurfaceVariant,
              ),
            );
          }

          final voucherCount = controller.requestedVoucherCount;
          if (voucherCount <= 0) {
            return Text(
              'أدخل عدد كروت أكبر من صفر لعرض التفكيك.',
              style: AppTypography.bodySmall.copyWith(color: colors.error),
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
              border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
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
                        'إجمالي الكروت المطلوبة للإرسال للنظام',
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
                        'المعادل تقريباً: $breakdown',
                        style: AppTypography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.vXxs,
                      Text(
                        'سعة الورقة لهذه الباقة: ${package.packageVoucherCount} كرت',
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
