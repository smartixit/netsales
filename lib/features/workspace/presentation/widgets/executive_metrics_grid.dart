import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// Feature adapter between server-backed workspace KPIs and shared metric cards.
class ExecutiveMetricsGrid extends StatelessWidget {
  const ExecutiveMetricsGrid({
    super.key,
    required this.items,
    required this.onPointsOfSaleTap,
    required this.onRequestsTap,
    required this.onPackagesTap,
    required this.onSalesTap,
    required this.onExpensesTap,
  });

  final List<DashboardMetricData> items;
  final VoidCallback onPointsOfSaleTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onPackagesTap;
  final VoidCallback onSalesTap;
  final VoidCallback onExpensesTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // The reference dashboard has exactly three top-level operational KPIs.
    // Sales is represented by the trend panel; secondary financial metrics
    // are intentionally not duplicated in this compact mobile summary.
    final summaryMetrics = items
        .where((item) => const {'pos', 'requests', 'packages'}.contains(item.id))
        .toList(growable: false);
    if (summaryMetrics.isEmpty) return const SizedBox.shrink();

    return NetSalesDashboardMetricsThemeAdapter.wrap(
      context: context,
      child: DashboardMetricGrid(
        metrics: summaryMetrics,
        minimumCardWidth: 100.w,
        maximumColumns: 3,
        onMetricTap: (id) {
          switch (id) {
            case 'pos':
              onPointsOfSaleTap();
            case 'requests':
              onRequestsTap();
            case 'packages':
              onPackagesTap();
            case 'sales':
              onSalesTap();
            case 'expenses':
              onExpensesTap();
          }
        },
      ),
    );
  }
}
