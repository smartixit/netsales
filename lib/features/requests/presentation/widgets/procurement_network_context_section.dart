import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_selector.dart';

/// Adapts linked Network entities to the shared procurement context selector.
class ProcurementNetworkContextSection
    extends GetView<PosNewProcurementOrderController> {
  const ProcurementNetworkContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final isEditMode = controller.isEditing.value;
      final links = controller.linkedNetworks;
      final selected = links.firstWhereOrNull(
        (link) => link.networkId == controller.selectedNetworkId.value,
      );
      final isExpanded =
          controller.expandedProcurementContext.value == 'network';

      return ProcurementContextSelector(
        title: 'الشبكة المورّدة',
        subtitle: isEditMode
            ? 'الجهة المورّدة للطلب (أطراف الطلب ثابتة أثناء التعديل)'
            : 'الجهة التي ستوفر الباقات والأسعار لهذا الطلب',
        icon: Icons.cell_tower_rounded,
        accent: colors.primary,
        selectedName: selected?.network?.networkName ?? 'اختر الشبكة المورّدة',
        selectedDetail:
            selected?.network?.networkAddress ??
            'حدد الشبكة المرتبطة بنقطة البيع',
        selectedLogoUrl: selected?.network?.networkProfileLogoUrl,
        selectedInitial: TextFormatter.avatarInitial(
          selected?.network?.networkName,
          fallback: 'ش',
        ),
        isExpanded: isExpanded,
        canExpand: !isEditMode && links.length > 1,
        isReadOnly: isEditMode,
        readOnlyBadgeText: 'للقراءة فقط',
        isLoading: controller.isLoadingNetworks.value,
        emptyMessage: links.isEmpty
            ? 'لا توجد شبكات مورّدة نشطة مرتبطة بنقطة البيع حالياً.'
            : null,
        onToggle: () {
          if (isEditMode) return;
          controller.expandedProcurementContext.value = isExpanded
              ? ''
              : 'network';
        },
        options: links
            .map(
              (link) => ProcurementContextOption(
                id: link.networkId,
                name: link.network?.networkName ?? 'شبكة #${link.networkId}',
                detail: link.network?.networkAddress ?? 'شبكة مورّدة مرتبطة',
                logoUrl: link.network?.networkProfileLogoUrl,
                initial: TextFormatter.avatarInitial(
                  link.network?.networkName,
                  fallback: 'ش',
                ),
                selected: link.networkId == controller.selectedNetworkId.value,
                onTap: () => controller.onNetworkSelected(link.networkId),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}
