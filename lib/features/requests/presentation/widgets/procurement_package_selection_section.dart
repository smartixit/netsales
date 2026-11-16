import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_radius.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/core/utils/amount_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_pricing_discount_card.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';
import 'package:netsales/widgets/pickers/custom_color_picker.dart';

/// اختيار الباقة وعرض السعر والخصم المخصص.
class ProcurementPackageSelectionSection extends GetView<PosProcurementController> {
  const ProcurementPackageSelectionSection({super.key});

  @override
  /// قسم اختيار باقة الكروت والتسعير المعتمد
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'باقة الكروت المطلوبة',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Obx(() {
          if (controller.isLoadingPackages.value) {
            return const LinearProgressIndicator();
          }

          final packages = controller.availablePackages;
          if (packages.isEmpty) {
            return Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'يرجى اختيار شبكة لعرض باقات الكروت المتوفرة لديها.',
                style: AppTypography.bodySmall.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown<int>(
                label: 'اختر باقة الكروت',
                searchEnabled: true,
                rxValue: controller.selectedPackageId,
                items: packages.map((pkg) {
                  final pkgColor = CustomColorPicker.parseHex(pkg.packageColor);
                  return DropdownItem<int>(
                    value: pkg.packageId,
                    child: Row(
                      children: [
                        Container(
                          width: 10.r,
                          height: 10.r,
                          decoration: BoxDecoration(
                            color: pkgColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hSm,
                        Expanded(
                          child: Text(
                            '${pkg.packageName} (أساسي: ${AmountFormatter.format(pkg.packageVoucherPrice.toString())})',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (id) {
                  if (id != null) {
                    final found = packages.firstWhereOrNull(
                      (p) => p.packageId == id,
                    );
                    if (found != null) controller.onPackageSelected(found);
                  }
                },
              ),
              if (controller.selectedPackage.value != null) ...[
                AppSpacing.vSm,
                ProcurementPricingDiscountCard(
                  package: controller.selectedPackage.value!,
                  discount: controller.effectiveDiscount.value,
                  isLoading: controller.isLoadingDiscount.value,
                  errorMessage: controller.discountError.value,
                  saleType: controller.selectedSaleType.value,
                ),
              ],
            ],
          );
        }),
      ],
    );
  }
}
