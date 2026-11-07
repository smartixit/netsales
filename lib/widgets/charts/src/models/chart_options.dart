import 'package:flutter/foundation.dart';

import '../enums/chart_axis_kind.dart';
import 'chart_axis_config.dart';
import 'chart_error_bar_config.dart';

@immutable
class ChartOptions {
  const ChartOptions({
    this.xAxis = const ChartAxisConfig(),
    this.yAxis = const ChartAxisConfig(kind: ChartAxisKind.numeric),
    this.additionalAxes = const <ChartAxisConfig>[],
    this.showLegend = true,
    this.showTooltip = true,
    this.showDataLabels = false,
    this.showMarkers = false,
    this.showMajorGridLines = true,
    this.enableTrackball = false,
    this.enableCrosshair = false,
    this.enableZoom = false,
    this.enablePinching = true,
    this.enablePanning = true,
    this.enableSelectionZooming = false,
    this.enableMouseWheelZooming = false,
    this.isTransposed = false,
    this.animate = true,
    this.animationDuration = 650,
    this.legendAtBottom = true,
    this.showMeanInBoxPlot = false,
    this.solidCandles = false,
    this.autoScrollingDelta,
    this.errorBar = const ChartErrorBarConfig(),
  }) : assert(animationDuration >= 0),
       assert(autoScrollingDelta == null || autoScrollingDelta > 0);

  final ChartAxisConfig xAxis;
  final ChartAxisConfig yAxis;
  final List<ChartAxisConfig> additionalAxes;
  final bool showLegend;
  final bool showTooltip;
  final bool showDataLabels;
  final bool showMarkers;
  final bool showMajorGridLines;
  final bool enableTrackball;
  final bool enableCrosshair;
  final bool enableZoom;
  final bool enablePinching;
  final bool enablePanning;
  final bool enableSelectionZooming;
  final bool enableMouseWheelZooming;
  final bool isTransposed;
  final bool animate;
  final int animationDuration;
  final bool legendAtBottom;
  final bool showMeanInBoxPlot;
  final bool solidCandles;

  /// Number of recent data points kept visible on the primary X axis.
  /// This is an item count, matching Syncfusion ChartAxis.autoScrollingDelta.
  final int? autoScrollingDelta;

  final ChartErrorBarConfig errorBar;
}
