import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netsales/core/themes/app_breakpoints.dart';
import 'package:netsales/widgets/dashboard_metrics/adapters/netsales_dashboard_metrics_theme_adapter.dart';
import 'package:netsales/widgets/dashboard_metrics/dashboard_metrics.dart';
import 'package:netsales/widgets/feedback/custom_skeleton_shimmer.dart';

/// ويدجت عرض بحت لشبكة المؤشرات التنفيذية (Pure Presentation Component)
/// خالية تماماً من أي منطق تجاري أو فلترة، وتعرض فقط ما يتم تزويده بها من المواءم والمتحكم.
class ExecutiveMetricsGrid extends StatelessWidget {
  const ExecutiveMetricsGrid({
    super.key,
    required this.items,
    this.isLoading = false,
    this.onMetricTap,
    this.onPointsOfSaleTap,
    this.onRequestsTap,
    this.onPackagesTap,
  });

  final List<DashboardMetricData> items;
  final bool isLoading;
  final ValueChanged<String>? onMetricTap;
  final VoidCallback? onPointsOfSaleTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onPackagesTap;

  static final List<DashboardMetricData> _placeholderMetrics = List.generate(
    4,
    (index) => DashboardMetricData(
      id: 'placeholder_$index',
      title: '',
      value: '',
      tone: DashboardMetricTone.neutral,
      variant: DashboardMetricVariant.standard,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && !isLoading) return const SizedBox.shrink();

    final columns = AppBreakpoints.kpiColumnsFor(context).clamp(1, 4);
    final minCardWidth = AppBreakpoints.isMobile(context) ? 140.w : 170.w;
    final displayMetrics = (items.isEmpty && isLoading)
        ? _placeholderMetrics
        : items;

    final grid = DashboardMetricGrid(
      metrics: displayMetrics,
      state: isLoading
          ? DashboardMetricState.loading
          : DashboardMetricState.data,
      minimumCardWidth: minCardWidth,
      maximumColumns: columns,
      onMetricTap: (id) {
        if (isLoading) return;
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
        }
      },
    );

    return NetSalesDashboardMetricsThemeAdapter.wrap(
      context: context,
      child: isLoading ? CustomSkeletonShimmer(child: grid) : grid,
    );
  }
}
