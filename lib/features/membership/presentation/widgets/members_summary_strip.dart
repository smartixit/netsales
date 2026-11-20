import 'package:flutter/material.dart';
import 'package:netsales/core/enums/membership_status.dart';
import 'package:netsales/core/presentation/enums/enum_presentation_registry.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط ملخص مؤشرات أعضاء المنشأة التفاعلي مستنداً إلى [CustomStatusSummaryStrip]
///
/// يستهلك مباشرة محرك العرض الموحد [EnumPresentationRegistry] لمنع تكرار النصوص أو الألوان أو الأيقونات.
class MembersSummaryStrip extends StatelessWidget {
  const MembersSummaryStrip({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.suspendedCount,
    required this.invitedCount,
    this.isLoading = false,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int activeCount;
  final int suspendedCount;
  final int invitedCount;
  final bool isLoading;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final active = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.active,
    );
    final suspended = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.suspended,
    );
    final invited = EnumPresentationRegistry.resolveMembershipStatus(
      MembershipStatus.invited,
    );

    final cards = [
      CustomKpiCardData(
        label: 'إجمالي الفريق',
        count: totalCount,
        statusKey: null,
        icon: Icons.groups_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: active.label,
        count: activeCount,
        statusKey: MembershipStatus.active.wireValue,
        icon: active.icon ?? Icons.check_circle_rounded,
        accentColor: active.tone.resolveColor(colors),
      ),
      CustomKpiCardData(
        label: suspended.label,
        count: suspendedCount,
        statusKey: MembershipStatus.suspended.wireValue,
        icon: suspended.icon ?? Icons.pause_circle_rounded,
        accentColor: suspended.tone.resolveColor(colors),
      ),
      if (invitedCount > 0)
        CustomKpiCardData(
          label: invited.label,
          count: invitedCount,
          statusKey: MembershipStatus.invited.wireValue,
          icon: invited.icon ?? Icons.hourglass_top_rounded,
          accentColor: invited.tone.resolveColor(colors),
        ),
    ];

    return CustomStatusSummaryStrip(
      cards: cards,
      selectedKey: selectedStatus,
      isLoading: isLoading,
      onSelectKey: onStatusTap,
    );
  }
}
