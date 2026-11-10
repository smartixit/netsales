import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// Editable list of direct invoice lines. No client-side prices or totals.
class DirectInvoiceCartSection extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoiceCartSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      if (controller.cart.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: colors.onSurfaceVariant,
                size: 28,
              ),
              AppSpacing.vSm,
              Text(
                'لم تتم إضافة أي باقة بعد',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.vXxs,
              Text(
                'اختر باقة وحدد عدد الكروت لإضافتها إلى الفاتورة.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'بنود الفاتورة (${controller.cart.length})',
                  style: AppTypography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CustomButton.outline(
                text: 'إفراغ البنود',
                size: AppButtonSize.small,
                onPressed: controller.clearCart,
              ),
            ],
          ),
          AppSpacing.vSm,
          for (final line in controller.cart)
            Builder(builder: (context) {
              final packageColor =
                  CustomColorPicker.parseHex(line.package.packageColor);

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
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
                          Container(
                            width: 5,
                            color: packageColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color:
                                          packageColor.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Icon(
                                      Icons.wifi_tethering_rounded,
                                      color: packageColor,
                                      size: 19,
                                    ),
                                  ),
                                  AppSpacing.hSm,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          line.package.packageName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              AppTypography.bodyMedium.copyWith(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        AppSpacing.vXxs,
                                        Text(
                                          line.fullQuantityLabel,
                                          style:
                                              AppTypography.bodySmall.copyWith(
                                            color: colors.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomButton.icon(
                                    icon: Icons.remove_rounded,
                                    tooltip: 'تقليل الكمية',
                                    dimension: 32,
                                    iconSize: 17,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: colors.onSurfaceVariant,
                                    onPressed: line.voucherCount > 1
                                        ? () => controller.updateLineQuantity(
                                              line.package.packageId,
                                              line.voucherCount - 1,
                                            )
                                        : null,
                                  ),
                                  Text(
                                    line.voucherCount.toString(),
                                    style: AppTypography.titleSmall.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  CustomButton.icon(
                                    icon: Icons.add_rounded,
                                    tooltip: 'زيادة الكمية',
                                    dimension: 32,
                                    iconSize: 17,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: colors.primary,
                                    onPressed: () =>
                                        controller.updateLineQuantity(
                                      line.package.packageId,
                                      line.voucherCount + 1,
                                    ),
                                  ),
                                  CustomButton.icon(
                                    icon: Icons.delete_outline_rounded,
                                    tooltip: 'حذف الباقة',
                                    dimension: 32,
                                    iconSize: 17,
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: colors.error,
                                    onPressed: () => controller.removeLine(
                                      line.package.packageId,
                                    ),
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
