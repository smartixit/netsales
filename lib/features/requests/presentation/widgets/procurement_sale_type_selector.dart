import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// محدد نوع البيع النقدي/الآجل، مع مراقبة مستقلة لحالة الاختيار.
class ProcurementSaleTypeSelector
    extends GetView<PosNewProcurementOrderController> {
  const ProcurementSaleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cashPres = EnumPresentationRegistry.resolveSaleType(SaleType.cash);

    return CustomSegmentedBar(
      selectedIndex: 0,
      onSegmentChanged: (_) {},
      items: [
        CustomSegmentItem(
          label: cashPres.label,
          icon: cashPres.icon ?? Icons.payments_outlined,
        ),
      ],
    );
  }
}
