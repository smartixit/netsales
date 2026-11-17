import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/buttons/custom_button.dart';
import 'package:netsales/widgets/inputs/voucher_quantity_stepper.dart';
import 'package:netsales/widgets/sheets/custom_bottom_sheet.dart';

/// محرر ثانوي للكمية الدقيقة؛ يُفتح عند الحاجة ولا يزاحم بطاقة الباقة.
class ProcurementQuantityEditorSheet extends GetView<PosProcurementController> {
  const ProcurementQuantityEditorSheet({super.key, required this.package});

  final PackageEntity package;

  static Future<void> show({
    required PackageEntity package,
    required int currentQuantity,
  }) async {
    final controller = Get.find<PosProcurementController>();
    controller.preparePackageQuantityEdit(package, currentQuantity);

    await CustomBottomSheet.show<void>(
      title: 'تعديل كمية ${package.packageName}',
      subtitle:
          'سعة الورقة ${package.packageVoucherCount} كرت، ويمكنك إدخال أي كمية دون التقيد بمضاعفات الأوراق.',
      leadingIcon: Icons.tune_rounded,
      scrollable: true,
      maxHeightFactor: 0.88,
      padding: EdgeInsets.all(AppSpacing.md),
      child: ProcurementQuantityEditorSheet(package: package),
      actions: [
        CustomButton.primary(
          text: 'تطبيق الكمية',
          onPressed: () {
            controller.setPackageVoucherCount(
              package,
              controller.requestedVoucherCount,
            );
            Get.back<void>();
          },
        ),
        CustomButton.text(text: 'إلغاء', onPressed: () => Get.back<void>()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => VoucherQuantityStepper(
        controller: controller.quantityController,
        sheetSize: package.packageVoucherCount,
        currentCount: controller.requestedVoucherCount,
        label: 'عدد الكروت المطلوبة',
        showPresets: true,
        presetLimit: 4,
        showSummaryCard: false,
        showClearAction: true,
        onCountChanged: controller.setVoucherCount,
      ),
    );
  }
}
