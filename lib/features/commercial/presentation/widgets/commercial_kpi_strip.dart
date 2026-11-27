import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/commercial/presentation/controllers/base_commercial_directory_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط مؤشرات دليل الشركاء؛ ألوانه مشتقة من Theme ولا تُنشأ داخل Controller.
class CommercialKpiStrip extends StatelessWidget {
  const CommercialKpiStrip({super.key, required this.controller});

  final BaseCommercialDirectoryController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = EnumPresentationRegistry.resolveLinkStatus(true);
    final inactive = EnumPresentationRegistry.resolveLinkStatus(false);

    return Obx(() => CustomStatusSummaryStrip(
      cards: [
        CustomKpiCardData(label: 'الكل', count: controller.totalPartnersCount,
          icon: Icons.all_inbox_rounded, accentColor: colors.primary, statusKey: null),
        CustomKpiCardData(label: active.label, count: controller.activePartnersCount,
          icon: active.icon ?? Icons.check_circle_rounded,
          accentColor: active.tone.color(context), statusKey: '1'),
        CustomKpiCardData(label: inactive.label, count: controller.inactivePartnersCount,
          icon: inactive.icon ?? Icons.pause_circle_rounded,
          accentColor: inactive.tone.color(context), statusKey: '0'),
      ],
      isLoading: controller.isLoading.value && controller.links.isEmpty,
      selectedKey: controller.statusFilter.value,
      onSelectKey: controller.setStatusFilter,
    ));
  }
}
