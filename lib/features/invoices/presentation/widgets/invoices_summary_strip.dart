import 'package:flutter/material.dart';
import 'package:netsales/core/themes/app_colors.dart';
import 'package:netsales/widgets/cards/custom_kpi_card_data.dart';
import 'package:netsales/widgets/indicators/custom_status_summary_strip.dart';

/// شريط ملخص مؤشرات حالات الفواتير التفاعلي مستنداً إلى [CustomStatusSummaryStrip]
class InvoicesSummaryStrip extends StatelessWidget {
  const InvoicesSummaryStrip({
    super.key,
    required this.totalCount,
    required this.paidCount,
    required this.partiallyPaidCount,
    required this.unpaidCount,
    this.isLoading = false,
    this.isNetworkView = false,
    this.selectedStatus,
    this.onStatusTap,
  });

  final int totalCount;
  final int paidCount;
  final int partiallyPaidCount;
  final int unpaidCount;
  final bool isLoading;
  final bool isNetworkView;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final cards = [
      CustomKpiCardData(
        label: isNetworkView ? 'فواتير المبيعات' : 'فواتير المشتريات',
        count: totalCount,
        statusKey: null,
        icon: Icons.receipt_long_rounded,
        accentColor: colors.primary,
      ),
      CustomKpiCardData(
        label: 'مسددة بالكامل',
        count: paidCount,
        statusKey: 'PAID',
        icon: Icons.check_circle_rounded,
        accentColor: colors.success,
      ),
      CustomKpiCardData(
        label: 'سداد جزئي',
        count: partiallyPaidCount,
        statusKey: 'PARTIALLY_PAID',
        icon: Icons.pie_chart_rounded,
        accentColor: colors.warning,
      ),
      CustomKpiCardData(
        label: 'غير مسددة',
        count: unpaidCount,
        statusKey: 'UNPAID',
        icon: Icons.error_outline_rounded,
        accentColor: colors.error,
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
