import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط ملخص مؤشرات حالات الطلبات التفاعلي مستنداً إلى [CustomStatusSummaryStrip]
class ProcurementOrdersSummaryStrip extends StatelessWidget {
  const ProcurementOrdersSummaryStrip({
    super.key,
    required this.totalCount,
    required this.pendingCount,
    required this.approvedCount,
    this.rejectedCount = 0,
    this.cancelledCount = 0,
    this.isLoading = false,
    this.isNetworkView = false,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int cancelledCount;
  final bool isLoading;
  final bool isNetworkView;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      CustomKpiCardData(
        label: isNetworkView ? 'الطلبات الواردة' : 'إجمالي الطلبات',
        count: totalCount,
        statusKey: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: isNetworkView ? 'بانتظار الاعتماد' : 'قيد المراجعة',
        count: pendingCount,
        statusKey: 'PENDING',
        icon: Icons.hourglass_top_rounded,
        accentColor: colors.warning,
      ),
      CustomKpiCardData(
        label: 'معتمدة',
        count: approvedCount,
        statusKey: 'APPROVED',
        icon: Icons.check_circle_rounded,
        accentColor: colors.success,
      ),
      CustomKpiCardData(
        label: 'مرفوضة',
        count: rejectedCount,
        statusKey: 'REJECTED',
        icon: Icons.cancel_outlined,
        accentColor: colors.error,
      ),
      CustomKpiCardData(
        label: 'ملغية',
        count: cancelledCount,
        statusKey: 'CANCELLED',
        icon: Icons.block_rounded,
        accentColor: colors.onSurfaceVariant,
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
