import 'package:flutter/foundation.dart';

import 'chart_data_point.dart';

/// Data passed to the host when a chart data point is tapped.
@immutable
class ChartPointInteraction {
  const ChartPointInteraction({
    required this.seriesId,
    required this.seriesName,
    required this.seriesIndex,
    required this.pointIndex,
    required this.point,
  });

  final String seriesId;
  final String seriesName;
  final int seriesIndex;
  final int pointIndex;
  final ChartDataPoint point;
}
