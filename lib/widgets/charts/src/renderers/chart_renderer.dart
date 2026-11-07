import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../enums/chart_family.dart';
import '../enums/chart_state.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../realtime/chart_live_data_source.dart';
import '../widgets/chart_state_view.dart';
import 'cartesian_chart_renderer.dart';
import 'circular_chart_renderer.dart';
import 'funnel_chart_renderer.dart';
import 'spark_chart_renderer.dart';

/// Shared Syncfusion rendering entry point for all seven chart families.
///
/// This low-level shared wrapper is stateful only to bind/unbind the
/// imperative Syncfusion series-controller callbacks safely. It does not own
/// feature or business state; NetSales feature state remains in GetX.
class ChartRenderer extends StatefulWidget {
  const ChartRenderer({
    super.key,
    required this.definition,
    this.onPointTap,
    this.onRetry,
  });

  final ChartDefinition definition;
  final ValueChanged<ChartPointInteraction>? onPointTap;
  final VoidCallback? onRetry;

  @override
  State<ChartRenderer> createState() => _ChartRendererState();
}

class _ChartRendererState extends State<ChartRenderer> {
  Set<ChartLiveDataSource<dynamic>> _sources(ChartDefinition definition) {
    return definition.series
        .map((series) => series.liveDataSource)
        .whereType<ChartLiveDataSource<dynamic>>()
        .toSet();
  }

  @override
  void didUpdateWidget(covariant ChartRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = _sources(oldWidget.definition);
    final current = _sources(widget.definition);
    for (final source in previous.difference(current)) {
      source.unbind();
    }
  }

  @override
  void dispose() {
    for (final source in _sources(widget.definition)) {
      source.unbind();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    if (definition.state != ChartState.data) {
      return ChartStateView(
        state: definition.state,
        message: definition.stateMessage,
        details: definition.stateDetails,
        onRetry: widget.onRetry,
      );
    }

    if (!definition.hasData) {
      return const ChartStateView(state: ChartState.empty);
    }

    return switch (definition.family) {
      ChartFamily.cartesian || ChartFamily.comparison ||
      ChartFamily.statistical || ChartFamily.financial =>
        CartesianChartRenderer(
          key: ValueKey<Object>(
            Object.hash(
              definition.series.map((series) => series.id).join('|'),
              definition.series
                  .map((series) => identityHashCode(series.liveDataSource))
                  .join('|'),
            ),
          ),
          definition: definition,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.circular => CircularChartRenderer(
          definition: definition,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.funnel => FunnelChartRenderer(
          definition: definition,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.spark => SparkChartRenderer(definition: definition),
    };
  }
}

/// Converts Syncfusion's point callback indexes into the neutral public event.
ChartPointInteraction? resolveChartPointInteraction({
  required List<ChartSeries> series,
  required int? seriesIndex,
  required int? pointIndex,
}) {
  if (seriesIndex == null ||
      pointIndex == null ||
      seriesIndex < 0 ||
      seriesIndex >= series.length) {
    return null;
  }

  final item = series[seriesIndex];
  final data = item.dataSource;
  if (pointIndex < 0 || pointIndex >= data.length) {
    return null;
  }

  return ChartPointInteraction(
    seriesId: item.id,
    seriesName: item.name,
    seriesIndex: seriesIndex,
    pointIndex: pointIndex,
    point: data[pointIndex],
  );
}
