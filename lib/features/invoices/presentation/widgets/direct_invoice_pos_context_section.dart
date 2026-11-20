import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/invoices/presentation/controllers/network_direct_invoice_controller.dart';
import 'package:netsales/widgets/inputs/custom_context_option.dart';
import 'package:netsales/widgets/inputs/custom_context_selector.dart';

/// بطاقة سياق واختيار نقطة البيع المستلمة للفاتورة
class DirectInvoicePosContextSection
    extends GetView<NetworkDirectInvoiceController> {
  const DirectInvoicePosContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final links = controller.posLinks;
      final selectedLink = controller.selectedPosLink;
      final isExpanded = controller.isPosContextExpanded.value;

      return CustomContextSelector(
        title: 'نقطة البيع المستلمة',
        subtitle: 'الموقع التجاري الذي سيتم إصدار الفاتورة وتوريد الكروت له',
        icon: Icons.storefront_rounded,
        accent: colors.secondary,
        selectedName: selectedLink?.displayPosName ?? 'اختر نقطة البيع',
        selectedDetail: selectedLink?.pos?.posAddress ?? 'نقطة بيع معتمدة',
        selectedLogoUrl: selectedLink?.pos?.posProfileLogoUrl,
        selectedInitial: TextFormatter.avatarInitial(
          selectedLink?.displayPosName,
          fallback: 'ن',
        ),
        isExpanded: isExpanded,
        canExpand: links.length > 1,
        isLoading: controller.isLoadingPosList.value,
        emptyMessage: links.isEmpty && !controller.isLoadingPosList.value
            ? 'لا توجد نقاط بيع مرتبطة بشبكتك حالياً.'
            : null,
        onToggle: controller.togglePosContextExpansion,
        options: links
            .map(
              (link) => CustomContextOption(
                id: link.posId,
                name: link.displayPosName,
                detail: link.pos?.posAddress ?? 'نقطة بيع معتمدة',
                logoUrl: link.pos?.posProfileLogoUrl,
                initial: TextFormatter.avatarInitial(
                  link.displayPosName,
                  fallback: 'ن',
                ),
                selected: link.posId == controller.selectedPosId.value,
                onTap: () => controller.selectPos(link.posId),
              ),
            )
            .toList(),
      );
    });
  }
}
