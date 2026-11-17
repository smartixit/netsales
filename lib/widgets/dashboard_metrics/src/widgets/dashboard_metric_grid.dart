import 'package:flutter/material.dart';

import 'dashboard_metric_card.dart';
import '../models/dashboard_metric_data.dart';
import '../enums/dashboard_metric_state.dart';
import '../theme/dashboard_metrics_theme.dart';

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
    this.cardHeight,
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
  final double? cardHeight;
  final ValueChanged<String>? onMetricTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final gap = spacing ?? DashboardMetricsTheme.of(context).gridSpacing;
        final columns = ((availableWidth + gap) / (minimumCardWidth + gap))
            .floor()
            .clamp(1, maximumColumns);
        if (metrics.isEmpty) {
          return const SizedBox.shrink();
        }

        final rows = <List<DashboardMetricData>>[];
        for (var i = 0; i < metrics.length; i += columns) {
          final end = (i + columns < metrics.length)
              ? i + columns
              : metrics.length;
          rows.add(metrics.sublist(i, end));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: runSpacing ?? gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < columns; c++) ...[
                      if (c > 0) SizedBox(width: gap),
                      Expanded(
                        child: c < rows[r].length
                            ? DashboardMetricCard(
                                metric: rows[r][c],
                                state: state,
                                height: cardHeight,
                                onTap: onMetricTap == null
                                    ? null
                                    : () => onMetricTap!(rows[r][c].id),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
