import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_procurement_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// محدد نوع البيع النقدي/الآجل، مع مراقبة مستقلة لحالة الاختيار.
class ProcurementSaleTypeSelector extends GetView<PosProcurementController> {
  const ProcurementSaleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex =
          controller.selectedSaleType.value == SaleType.cash ? 0 : 1;

      return CustomSegmentedBar(
        selectedIndex: selectedIndex,
        onSegmentChanged: (index) {
          controller.selectedSaleType.value =
              index == 0 ? SaleType.cash : SaleType.credit;
        },
        items: const [
          CustomSegmentItem(
            label: 'نقدي',
            icon: Icons.payments_outlined,
          ),
          CustomSegmentItem(
            label: 'آجل',
            icon: Icons.credit_card_outlined,
          ),
        ],
      );
    });
  }
}
