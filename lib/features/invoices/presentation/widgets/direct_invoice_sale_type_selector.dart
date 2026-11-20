import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// محدد نوع البيع النقدي/الآجل للفاتورة المباشرة
class DirectInvoiceSaleTypeSelector
    extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoiceSaleTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cashPres = EnumPresentationRegistry.resolveSaleType(SaleType.cash);
    final creditPres = EnumPresentationRegistry.resolveSaleType(
      SaleType.credit,
    );

    return Obx(
      () => CustomSegmentedBar(
        selectedIndex: controller.selectedSaleTypeIndex.value,
        onSegmentChanged: controller.setSaleTypeIndex,
        items: [
          CustomSegmentItem(
            label: cashPres.label,
            icon: cashPres.icon ?? Icons.payments_outlined,
          ),
          CustomSegmentItem(
            label: creditPres.label,
            icon: creditPres.icon ?? Icons.credit_score_rounded,
          ),
        ],
      ),
    );
  }
}
