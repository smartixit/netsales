import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// Feature adapter between server-backed workspace KPIs and shared metric cards.
///
/// يعرض مؤشرات الأداء التشغيلية الثلاثة الرئيسية (نقاط البيع، طلبات التوريد، باقات الكتالوج)
/// بتصميم متجاوب تماماً وفق معايير AppBreakpoints لمنع أي تكدس أو قص في النصوص والمحتويات.
class ExecutiveMetricsGrid extends StatelessWidget {
  const ExecutiveMetricsGrid({
    super.key,
    required this.items,
    required this.onPointsOfSaleTap,
    required this.onRequestsTap,
    required this.onPackagesTap,
  });

  final List<DashboardMetricData> items;
  final VoidCallback onPointsOfSaleTap;
  final VoidCallback onRequestsTap;
  final VoidCallback onPackagesTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // The compact reference exposes exactly these three operational KPIs.
    // Sales stays in the trend panel; expenses are not duplicated here.
    final summaryMetrics = items
        .where(
          (item) => const {'pos', 'requests', 'packages'}.contains(item.id),
        )
        .toList(growable: false);
    if (summaryMetrics.isEmpty) return const SizedBox.shrink();

    final columns = AppBreakpoints.kpiColumnsFor(context).clamp(1, 3);
    final minCardWidth = AppBreakpoints.isMobile(context) ? 145.w : 185.w;

    return NetSalesDashboardMetricsThemeAdapter.wrap(
      context: context,
      child: DashboardMetricGrid(
        metrics: summaryMetrics,
        minimumCardWidth: minCardWidth,
        maximumColumns: columns,
        onMetricTap: (id) {
          switch (id) {
            case 'pos':
              onPointsOfSaleTap();
            case 'requests':
              onRequestsTap();
            case 'packages':
              onPackagesTap();
          }
        },
      ),
    );
  }
}
