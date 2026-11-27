import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/features/membership/presentation/controllers/base_memberships_controller.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// مؤشرات العضويات. تُنشأ بيانات العرض هنا لأن الألوان تعتمد على Theme/BuildContext.
class MembershipKpiStrip extends StatelessWidget {
  const MembershipKpiStrip({super.key, required this.controller});

  final BaseMembershipsController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = EnumPresentationRegistry.resolveMembershipStatus(MembershipStatus.active);
    final suspended = EnumPresentationRegistry.resolveMembershipStatus(MembershipStatus.suspended);
    final invited = EnumPresentationRegistry.resolveMembershipStatus(MembershipStatus.invited);

    return Obx(() => CustomStatusSummaryStrip(
      cards: [
        CustomKpiCardData(label: 'الكل', count: controller.totalMembersCount,
          icon: Icons.people_alt_rounded, accentColor: colors.primary, statusKey: null),
        CustomKpiCardData(label: active.label, count: controller.activeMembersCount,
          icon: active.icon ?? Icons.check_circle_rounded,
          accentColor: active.tone.color(context), statusKey: MembershipStatus.active.wireValue),
        CustomKpiCardData(label: suspended.label, count: controller.suspendedMembersCount,
          icon: suspended.icon ?? Icons.pause_circle_outline_rounded,
          accentColor: suspended.tone.color(context), statusKey: MembershipStatus.suspended.wireValue),
        CustomKpiCardData(label: invited.label, count: controller.invitedMembersCount,
          icon: invited.icon ?? Icons.hourglass_top_rounded,
          accentColor: invited.tone.color(context), statusKey: MembershipStatus.invited.wireValue),
      ],
      isLoading: controller.isLoading.value && controller.members.isEmpty,
      selectedKey: controller.statusFilter.value,
      onSelectKey: controller.setStatusFilter,
    ));
  }
}
