import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط ملخص مؤشرات العلاقات التجارية التفاعلي مستنداً إلى [CustomStatusSummaryStrip]
class CommercialSummaryStrip extends StatelessWidget {
  const CommercialSummaryStrip({
    super.key,
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    this.isLoading = false,
    this.isNetworkView = true,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final bool isLoading;
  final bool isNetworkView;
  final bool? selectedStatus;
  final ValueChanged<bool?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      CustomKpiCardData(
        label: isNetworkView ? 'إجمالي النقاط' : 'إجمالي الشبكات',
        count: totalCount,
        statusKey: null,
        icon: isNetworkView ? Icons.storefront_rounded : Icons.hub_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: 'ارتباط نشط',
        count: activeCount,
        statusKey: 'ACTIVE',
        icon: Icons.check_circle_rounded,
        accentColor: colors.success,
      ),
      CustomKpiCardData(
        label: 'ارتباط مجمد',
        count: inactiveCount,
        statusKey: 'INACTIVE',
        icon: Icons.pause_circle_rounded,
        accentColor: colors.warning,
      ),
    ];

    String? selectedKey;
    if (selectedStatus == true) {
      selectedKey = 'ACTIVE';
    } else if (selectedStatus == false) {
      selectedKey = 'INACTIVE';
    }

    return CustomStatusSummaryStrip(
      cards: cards,
      selectedKey: selectedKey,
      isLoading: isLoading,
      onSelectKey: (key) {
        if (onStatusTap == null) return;
        if (key == 'ACTIVE') {
          onStatusTap!(true);
        } else if (key == 'INACTIVE') {
          onStatusTap!(false);
        } else {
          onStatusTap!(null);
        }
      },
    );
  }
}
