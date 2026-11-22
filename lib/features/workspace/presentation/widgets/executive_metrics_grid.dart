import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';

/// Feature adapter between server-backed workspace KPIs and shared metric cards.
///
/// يعرض مؤشرات الأداء التشغيلية والمالية الرئيسية (مبيعات اليوم، رصيد المحفظة، نقاط البيع، طلبات التوريد، باقات الكتالوج)
/// بتصميم متجاوب تماماً وفق معايير AppBreakpoints لمنع أي تكدس أو قص في النصوص والمحتويات.
class ExecutiveMetricsGrid extends StatelessWidget {
  const ExecutiveMetricsGrid({
    super.key,
    required this.items,
    this.onPointsOfSaleTap,
    this.onRequestsTap,
    this.onPackagesTap,
    this.onTodaySalesTap,
    this.onWalletTap,
    this.onMetricTap,
    this.restrictToOperationalSummary = false,
  });

  final List<DashboardMetricData> items;
  final VoidCallback? onPointsOfSaleTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onPackagesTap;
  final VoidCallback? onTodaySalesTap;
  final VoidCallback? onWalletTap;
  final ValueChanged<String>? onMetricTap;
  final bool restrictToOperationalSummary;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final metricsToDisplay = restrictToOperationalSummary
        ? items
            .where(
              (item) => const {'pos', 'requests', 'packages'}.contains(item.id),
            )
            .toList(growable: false)
        : items;
    if (metricsToDisplay.isEmpty) return const SizedBox.shrink();

    final columns = AppBreakpoints.kpiColumnsFor(context).clamp(1, 4);
    final minCardWidth = AppBreakpoints.isMobile(context) ? 145.w : 185.w;

    return NetSalesDashboardMetricsThemeAdapter.wrap(
      context: context,
      child: DashboardMetricGrid(
        metrics: metricsToDisplay,
        minimumCardWidth: minCardWidth,
        maximumColumns: columns,
        onMetricTap: (id) {
          if (onMetricTap != null) {
            onMetricTap!(id);
            return;
          }
          switch (id) {
            case 'pos':
              onPointsOfSaleTap?.call();
            case 'requests':
              onRequestsTap?.call();
            case 'packages':
              onPackagesTap?.call();
            case 'today_sales' || 'sales':
              onTodaySalesTap?.call();
            case 'wallet' || 'today_cash':
              onWalletTap?.call();
          }
        },
      ),
    );
  }
}
