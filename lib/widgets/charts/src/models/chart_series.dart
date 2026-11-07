import 'package:flutter/foundation.dart';
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
    this.width = 2.5,
    this.opacity = 0.88,
    this.isVisible = true,
    this.isVisibleInLegend = true,
    this.stackGroup,
    this.xAxisName,
    this.yAxisName,
    this.binInterval,
  });

  final String id;
  final String name;

  /// Overrides the definition's default type for mixed-series charts.
  final ChartType? type;
  final List<ChartDataPoint> data;
  final ChartLiveDataSource<ChartDataPoint>? liveDataSource;
  final Color? color;
  final double width;
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
