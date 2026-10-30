import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/inputs/custom_dropdown.dart';

/// ============================================================================
/// فلتر الشبكة لعقود الربط (PartnersNetworkFilter)
/// ============================================================================
/// غلاف رشيق (Lean Feature Adapter) يربط [PartnersController] بـ [CustomDropdown]
/// لتصفية عقود الربط (Network-POS) حسب الشبكة المحددة،
/// مماثلاً لأسلوب اختيار المحافظات/المديريات (cascading filter).
class PartnersNetworkFilter extends StatelessWidget {
  final PartnersController controller;

  const PartnersNetworkFilter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLinksTab = controller.activeSegmentIndex.value == 2;
      if (!isLinksTab) return const SizedBox.shrink();

      final networks = controller.networks;
      if (networks.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomDropdown<int>(
              label: 'تصفية حسب الشبكة',
              hint: 'جميع الشبكات',
              prefixIcon: Icons.cell_tower_rounded,
              valueListenable: controller.selectedNetworkId,
              items: [
                const DropdownItem<int>(value: null, child: Text('جميع الشبكات')),
                ...networks.map(
                  (net) => DropdownItem<int>(
                    value: net.networkId,
                    child: Text(net.networkName),
                  ),
                ),
              ],
              onChanged: (id) => controller.onNetworkFilterChanged(id),
            ),
            AppSpacing.vSm,
          ],
        ),
      );
    });
  }
}
