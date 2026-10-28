import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/constants/app_spacing.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/partners/presentation/controllers/partners_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card.dart';

/// ============================================================================
/// شريط المؤشرات الحيوية للشركاء (PartnersStatsHeader)
/// ============================================================================
/// يعرض مؤشرات KPI ديناميكية سريعة تتغير تلقائياً وبسلاسة حسب التبويب النشط.
class PartnersStatsHeader extends StatelessWidget {
  final PartnersController controller;

  const PartnersStatsHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final tab = controller.activeSegmentIndex.value;

      late final String title1, val1, u1;
      late final String title2, val2, u2;
      late final String title3, val3, u3;
      late final IconData icon1, icon2, icon3;
      late final Color col1, col2, col3;

      if (tab == 0) {
        // مزودو الشبكات
        title1 = 'إجمالي الشبكات';
        val1 = '${controller.totalNetworksCount}';
        u1 = 'شبكة';
        icon1 = Icons.hub_rounded;
        col1 = colors.primary;

        title2 = 'شبكات مفعّلة';
        val2 = '${controller.activeNetworksCount}';
        u2 = 'مفعّلة';
        icon2 = Icons.verified_rounded;
        col2 = colors.success;

        title3 = 'قيد المراجعة';
        val3 = '${controller.pendingNetworksCount}';
        u3 = 'معلقة';
        icon3 = Icons.pending_actions_rounded;
        col3 = controller.pendingNetworksCount > 0
            ? colors.warning
            : colors.onSurfaceVariant;
      } else if (tab == 1) {
        // نقاط البيع والوكلاء
        title1 = 'إجمالي الوكلاء';
        val1 = '${controller.totalPosCount}';
        u1 = 'وكيل';
        icon1 = Icons.storefront_rounded;
        col1 = colors.primary;

        title2 = 'وكلاء نشطون';
        val2 = '${controller.activePosCount}';
        u2 = 'مفعّل';
        icon2 = Icons.check_circle_rounded;
        col2 = colors.success;

        title3 = 'بانتظار الاعتماد';
        val3 = '${controller.pendingPosCount}';
        u3 = 'معلق';
        icon3 = Icons.hourglass_top_rounded;
        col3 = controller.pendingPosCount > 0
            ? colors.warning
            : colors.onSurfaceVariant;
      } else {
        // عقود الشراكة والتوزيع
        final inactiveCount =
            controller.totalLinksCount - controller.activeLinksCount;
        title1 = 'عقود التوزيع';
        val1 = '${controller.totalLinksCount}';
        u1 = 'عقد';
        icon1 = Icons.swap_horiz_rounded;
        col1 = colors.primary;

        title2 = 'عقود سارية';
        val2 = '${controller.activeLinksCount}';
        u2 = 'نشط';
        icon2 = Icons.link_rounded;
        col2 = colors.success;

        title3 = 'عقود مجمدة';
        val3 = '$inactiveCount';
        u3 = 'مجمد';
        icon3 = Icons.link_off_rounded;
        col3 = inactiveCount > 0 ? colors.error : colors.onSurfaceVariant;
      }

      return Row(
        children: [
          Expanded(
            child: CustomKpiCard.compact(
              title: title1,
              value: val1,
              unit: u1,
              icon: icon1,
              iconColor: col1,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: CustomKpiCard.compact(
              title: title2,
              value: val2,
              unit: u2,
              icon: icon2,
              iconColor: col2,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: CustomKpiCard.compact(
              title: title3,
              value: val3,
              unit: u3,
              icon: icon3,
              iconColor: col3,
            ),
          ),
        ],
      );
    });
  }
}
