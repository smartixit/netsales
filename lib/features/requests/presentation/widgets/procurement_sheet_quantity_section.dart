import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/inputs/voucher_quantity_stepper.dart';

/// واجهة إدخال كمية التوريد بعدد الكروت باستخدام المكون الموحد VoucherQuantityStepper
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
          'كمية طلب التوريد',
          style: AppTypography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.vXs,
        Text(
          'أدخل عدد الكروت المطلوبة مباشرة، أو استخدم أزرار الأوراق والكبسولات التراكمية السريعة.',
          style: AppTypography.bodySmall.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        AppSpacing.vSm,
        Obx(() {
          final package = controller.selectedPackage.value;
          final sheetSize = package?.packageVoucherCount ?? 0;
          final currentCount = controller.requestedVoucherCount;

          return VoucherQuantityStepper(
            controller: controller.quantityController,
            sheetSize: sheetSize,
            currentCount: currentCount,
            label: 'عدد الكروت المطلوبة',
            showPresets: sheetSize > 0,
            showSummaryCard: sheetSize > 0,
            showClearAction: true,
            validator: controller.validateVoucherQuantity,
            onCountChanged: controller.setVoucherCount,
          );
        }),
      ],
    );
  }
}
