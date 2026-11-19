import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// محدد نوع البيع النقدي/الآجل، مع مراقبة مستقلة لحالة الاختيار.
class ProcurementSaleTypeSelector
    extends GetView<PosNewProcurementOrderController> {
  const ProcurementSaleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomSegmentedBar(
        selectedIndex: controller.selectedSaleTypeIndex,
        onSegmentChanged: controller.setSaleTypeIndex,
        items: const [
          CustomSegmentItem(label: 'نقدي', icon: Icons.payments_outlined),
          CustomSegmentItem(label: 'آجل', icon: Icons.credit_card_outlined),
        ],
      ),
    );
  }
}
