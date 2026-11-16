
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/themes/app_typography.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/feedback/custom_empty_state.dart';
import 'package:netsales/widgets/inputs/voucher_quantity_stepper.dart';

/// تحكم كمية الباقة المحددة بوحدتي الكرت والورقة مع إدخال يدوي.
class ProcurementSheetQuantitySection
    extends GetView<PosProcurementController> {
  const ProcurementSheetQuantitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final package = controller.selectedPackage.value;
      if (package == null) {
        return const CustomEmptyState.compact(
          title: 'اختر باقة لبدء تحديد الكمية',
          subtitle: 'بعد اختيار الباقة ستظهر أزرار التحكم بالكروت والأوراق.',
          icon: Icons.touch_app_outlined,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كمية ${package.packageName}',
            style: AppTypography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vXxs,
          Text(
            'يمكنك إضافة أو إنقاص كرت واحد، أو تغيير الكمية بمقدار ورقة كاملة، أو إدخال العدد المطلوب مباشرة.',
            style: AppTypography.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          AppSpacing.vSm,
          VoucherQuantityStepper(
            controller: controller.quantityController,
            sheetSize: package.packageVoucherCount,
            currentCount: controller.requestedVoucherCount,
            label: 'عدد الكروت',
            showPresets: true,
            presetLimit: 4,
            showSummaryCard: false,
            showClearAction: true,
            validator: controller.validateVoucherQuantity,
            onCountChanged: controller.setVoucherCount,
          ),
        ],
      );
    });
  }
}
