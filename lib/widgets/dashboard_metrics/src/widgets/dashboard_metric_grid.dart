import 'package:flutter/material.dart';

import '../../../../core/themes/app_breakpoints.dart';
import 'dashboard_metric_card.dart';
import '../models/dashboard_metric_data.dart';
import '../enums/dashboard_metric_state.dart';

/// Constraint-driven KPI grid. Column count is selected from available width,
/// not the physical device type, so desktop split panes remain predictable.
class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({
    required this.metrics,
    this.state = DashboardMetricState.data,
    this.spacing,
    this.runSpacing,
    this.minimumCardWidth = 230,
    this.maximumColumns = 5,
    this.onMetricTap,
    super.key,
  }) : assert(minimumCardWidth > 0),
       assert(maximumColumns > 0);

  final List<DashboardMetricData> metrics;
  final DashboardMetricState state;
  final double? spacing;
  final double? runSpacing;
  final double minimumCardWidth;
  final int maximumColumns;
  final ValueChanged<String>? onMetricTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : AppBreakpoints.widthOf(context);
        final gap = spacing ?? AppBreakpoints.gridGutter(context);
        final columns = ((availableWidth + gap) / (minimumCardWidth + gap))
            .floor()
            .clamp(1, maximumColumns);
        final itemWidth = (availableWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: runSpacing ?? gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: itemWidth,
                child: DashboardMetricCard(
                  metric: metric,
                  state: state,
                  onTap: onMetricTap == null
                      ? null
                      : () => onMetricTap!(metric.id),
                ),
              ),
          ],
        );
      },
    );
  }
}
