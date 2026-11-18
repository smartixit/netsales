import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/core/utils/text_formatter.dart';
import 'package:netsales/features/requests/presentation/controllers/pos_new_procurement_order_controller.dart';
import 'package:netsales/features/requests/presentation/widgets/procurement_context_selector.dart';

/// Adapts the user's authorized POS entities to the shared context selector.
class ProcurementPosContextSection
    extends GetView<PosNewProcurementOrderController> {
  const ProcurementPosContextSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Obx(() {
      final positions = controller.myPosList;
      final selected = controller.activePos;
      final isExpanded = controller.expandedProcurementContext.value == 'pos';

      return ProcurementContextSelector(
        title: 'نقطة البيع',
        subtitle: 'الموقع الذي سيستلم الباقات المورّدة',
        icon: Icons.storefront_rounded,
        accent: colors.secondary,
        selectedName: selected?.posName ?? 'اختر نقطة البيع',
        selectedDetail:
            selected?.posAddress ?? 'نقطة البيع المحددة لتنفيذ الطلب',
        selectedLogoUrl: selected?.posProfileLogoUrl,
        selectedInitial: TextFormatter.avatarInitial(
          selected?.posName,
          fallback: 'ن',
        ),
        isExpanded: isExpanded,
        canExpand: positions.length > 1,
        isLoading: controller.isLoadingMyPos.value,
        emptyMessage: positions.isEmpty && !controller.isLoadingMyPos.value
            ? 'لا توجد نقاط بيع معتمدة ومصرح بها لحسابك حالياً.'
            : null,
        onToggle: () {
          controller.expandedProcurementContext.value = isExpanded ? '' : 'pos';
        },
        options: positions
            .map(
              (pos) => ProcurementContextOption(
                id: pos.posId,
                name: pos.posName,
                detail: pos.posAddress ?? 'نقطة بيع معتمدة',
                logoUrl: pos.posProfileLogoUrl,
                initial: TextFormatter.avatarInitial(
                  pos.posName,
                  fallback: 'ن',
                ),
                selected: pos.posId == controller.selectedPosId.value,
                onTap: () => controller.onPosSelected(pos.posId),
              ),
            )
            .toList(growable: false),
      );
    });
  }
}
