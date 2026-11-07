import 'package:flutter/material.dart';

import '../enums/chart_type.dart';
import '../realtime/chart_live_data_source.dart';
import 'chart_data_point.dart';

@immutable
class ChartSeries {
  const ChartSeries({
    required this.id,
    required this.name,
    this.type,
    this.data = const <ChartDataPoint>[],
    this.liveDataSource,
    this.color,
    this.seriesWidth = 0.7,
    this.strokeWidth = 2.5,
    this.opacity = 0.88,
    this.isVisible = true,
    this.isVisibleInLegend = true,
    this.stackGroup,
    this.xAxisName,
    this.yAxisName,
    this.binInterval,
  }) : assert(seriesWidth >= 0 && seriesWidth <= 1),
       assert(strokeWidth >= 0),
       assert(opacity >= 0 && opacity <= 1);

  final String id;
  final String name;

  /// Overrides the definition's default type for mixed-series charts.
  final ChartType? type;
  final List<ChartDataPoint> data;
  final ChartLiveDataSource<ChartDataPoint>? liveDataSource;
  final Color? color;
  /// Relative category/financial/box width expected by Syncfusion (0..1).
  final double seriesWidth;

  /// Stroke thickness in logical pixels for line, area and outline series.
  final double strokeWidth;
  final double opacity;
  final bool isVisible;
  final bool isVisibleInLegend;
  final String? stackGroup;
  final String? xAxisName;
  final String? yAxisName;
  final double? binInterval;

  /// The exact mutable list instance bound to the corresponding Syncfusion
  /// series. For live charts this is owned by [liveDataSource].
  List<ChartDataPoint> get dataSource => liveDataSource?.data ?? data;

  ChartType resolveType(ChartType fallback) => type ?? fallback;
}
