import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/indicators/custom_segmented_bar.dart';

/// ============================================================================
/// رأس التبويب القطاعي للشركاء والتوزيع (PartnersSegmentedHeader)
/// ============================================================================
/// غلاف رشيق (Lean Feature Adapter) يربط [CustomSegmentedBar] بـ [PartnersController].
class PartnersSegmentedHeader extends StatelessWidget {
  final PartnersController controller;

  const PartnersSegmentedHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomSegmentedBar(
        selectedIndex: controller.activeSegmentIndex.value,
        onSegmentChanged: controller.changeSegment,
        items: [
          CustomSegmentItem(
            label: 'شبكات الإنترنت',
            count: controller.networks.length,
            highlightBadge: controller.pendingNetworksCount > 0,
          ),
          CustomSegmentItem(
            label: 'نقاط البيع والوكلاء',
            count: controller.posList.length,
            highlightBadge: controller.pendingPosCount > 0,
          ),
          CustomSegmentItem(
            label: 'عقود التوزيع والربط',
            count: controller.networkPosList.length,
          ),
        ],
      ),
    );
  }
}
