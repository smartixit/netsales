import 'package:flutter/material.dart';

import '../enums/chart_family.dart';
import '../enums/chart_state.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../widgets/chart_state_view.dart';
import 'cartesian_chart_renderer.dart';
import 'circular_chart_renderer.dart';
import 'funnel_chart_renderer.dart';
import 'spark_chart_renderer.dart';

/// Shared Syncfusion rendering entry point for all seven chart families.
///
/// It owns only renderer callback registrations. Data sources remain owned by
/// the feature/controller that created them.
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
  static int _nextBindingScope = 0;

  late final String _bindingScope = 'chart-\${_nextBindingScope++}';

  String _bindingId(String seriesId) => '$_bindingScope:$seriesId';

  void _unbindSeries(Iterable<ChartSeries> series) {
    for (final item in series) {
      item.liveDataSource?.unbind(bindingId: _bindingId(item.id));
    }
  }

  @override
  void didUpdateWidget(covariant ChartRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldDefinition = oldWidget.definition;
    final newDefinition = widget.definition;
    final rendererWasReplaced =
        oldDefinition.state != ChartState.data ||
        newDefinition.state != ChartState.data ||
        oldDefinition.family != newDefinition.family;

    if (rendererWasReplaced) {
      _unbindSeries(oldDefinition.series);
      return;
    }

    for (final oldSeries in oldDefinition.series) {
      final isStillBound = newDefinition.series.any(
        (newSeries) =>
            newSeries.id == oldSeries.id &&
            identical(newSeries.liveDataSource, oldSeries.liveDataSource),
      );
      if (!isStillBound) {
        oldSeries.liveDataSource?.unbind(
          bindingId: _bindingId(oldSeries.id),
        );
      }
    }
  }

  @override
  void dispose() {
    _unbindSeries(widget.definition.series);
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
      ChartFamily.cartesian ||
      ChartFamily.comparison ||
      ChartFamily.statistical ||
      ChartFamily.financial =>
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
          bindingScope: _bindingScope,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.circular => CircularChartRenderer(
          definition: definition,
          bindingScope: _bindingScope,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.funnel => FunnelChartRenderer(
          definition: definition,
          bindingScope: _bindingScope,
          onPointTap: widget.onPointTap,
        ),
      ChartFamily.spark => SparkChartRenderer(definition: definition),
    };
  }
}

/// Converts Syncfusion point indexes to a framework-neutral callback model.
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
