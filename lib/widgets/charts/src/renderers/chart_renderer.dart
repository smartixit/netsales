import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

import '../enums/chart_family.dart';
import '../enums/chart_state.dart';
import '../controllers/chart_controller.dart';
import '../enums/chart_zoom_mode.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../widgets/chart_state_view.dart';
import 'cartesian_chart_renderer.dart';
import 'circular_chart_renderer.dart';
import 'funnel_chart_renderer.dart';
import 'spark_chart_renderer.dart';

class ChartRenderer extends StatefulWidget {
  const ChartRenderer({
    super.key,
    required this.definition,
    this.onPointTap,
    this.onRetry,
    this.controller,
  });

  final ChartDefinition definition;
  final ValueChanged<ChartPointInteraction>? onPointTap;
  final VoidCallback? onRetry;
  final ChartController? controller;

  @override
  State<ChartRenderer> createState() => _ChartRendererState();
}

class _ChartRendererState extends State<ChartRenderer> {
  static int _nextBindingScope = 0;

  late final String _bindingScope = 'chart-${_nextBindingScope++}';
  final Object _controllerOwner = Object();
  ZoomPanBehavior? _zoomPanBehavior;

  bool _isCartesian(ChartFamily family) => switch (family) {
    ChartFamily.cartesian ||
    ChartFamily.comparison ||
    ChartFamily.statistical ||
    ChartFamily.financial => true,
    _ => false,
  };

  ZoomPanBehavior? _createZoomBehavior(ChartDefinition definition) {
    final options = definition.options;
    if (!_isCartesian(definition.family) || !options.enableZoom) return null;
    return ZoomPanBehavior(
      enablePinching: options.enablePinching,
      enablePanning: options.enablePanning,
      enableSelectionZooming: options.enableSelectionZooming,
      enableMouseWheelZooming: options.enableMouseWheelZooming,
      enableDoubleTapZooming: options.enableDoubleTapZooming,
      enableDirectionalZooming: options.enableDirectionalZooming,
      zoomMode: switch (options.zoomMode) {
        ChartZoomMode.horizontal => ZoomMode.x,
        ChartZoomMode.vertical => ZoomMode.y,
        ChartZoomMode.both => ZoomMode.xy,
      },
    );
  }

  void _syncController() {
    final definition = widget.definition;
    final isRenderableCartesianChart =
        definition.state == ChartState.data &&
        definition.canRender &&
        _isCartesian(definition.family);
    final behavior = isRenderableCartesianChart ? _zoomPanBehavior : null;
    if (behavior == null) {
      widget.controller?.detach(_controllerOwner);
      return;
    }
    widget.controller?.attach(
      owner: _controllerOwner,
      reset: behavior.reset,
      zoomIn: behavior.zoomIn,
      zoomOut: behavior.zoomOut,
      pan: behavior.panToDirection,
    );
  }

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = _createZoomBehavior(widget.definition);
    _syncController();
  }

  String _bindingId(String seriesId) => '$_bindingScope:$seriesId';

  void _unbindSeries(Iterable<ChartSeries> series) {
    for (final item in series) {
      item.liveDataSource?.unbind(bindingId: _bindingId(item.id));
    }
  }

  @override
  void didUpdateWidget(covariant ChartRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?.detach(_controllerOwner);
    }
    if (oldWidget.definition.options != widget.definition.options ||
        oldWidget.definition.family != widget.definition.family) {
      _zoomPanBehavior = _createZoomBehavior(widget.definition);
    }
    _syncController();

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
    widget.controller?.detach(_controllerOwner);
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

    if (!definition.canRender) {
      return const ChartStateView(state: ChartState.empty);
    }

    return switch (definition.family) {
      ChartFamily.cartesian ||
      ChartFamily.comparison ||
      ChartFamily.statistical ||
      ChartFamily.financial => CartesianChartRenderer(
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
        zoomPanBehavior: _zoomPanBehavior,
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
