import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';

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
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
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
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: colors.primary,
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
                                  '${line.sheetsLabel} ورقة  •  ${line.voucherCount} كرت',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
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
              );
            }),
        ],
      );
    });
  }
}
