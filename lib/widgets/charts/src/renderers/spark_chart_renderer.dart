import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../enums/chart_type.dart';
import '../models/chart_definition.dart';
import '../theme/charts_theme.dart';

/// Syncfusion Spark renderer.
///
/// Spark widgets consume a numeric list. Their real-time path is therefore
/// listener-driven: the source emits a change, AnimatedBuilder rebuilds the
/// spark widget with its current bounded numeric values.
class SparkChartRenderer extends StatelessWidget {
  const SparkChartRenderer({super.key, required this.definition});

  final ChartDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final series = definition.series.first;
    final type = series.resolveType(definition.type);

    return AnimatedBuilder(
      animation: series.liveDataSource ?? _NoopListenable.instance,
      builder: (context, _) {
        final values = series.dataSource
            .map((point) => point.y?.toDouble() ?? 0.0)
            .toList(growable: false);
        final color = series.color ?? theme.primary;
        final trackball = SparkChartTrackball(
          activationMode: SparkChartActivationMode.tap,
        );
        final marker = SparkChartMarker(
          displayMode: definition.options.showMarkers
              ? SparkChartMarkerDisplayMode.all
              : SparkChartMarkerDisplayMode.none,
        );

        return switch (type) {
          ChartType.sparkLine => SfSparkLineChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              marker: marker,
              trackball: trackball,
              labelDisplayMode: definition.options.showDataLabels
                  ? SparkChartLabelDisplayMode.last
                  : SparkChartLabelDisplayMode.none,
            ),
          ChartType.sparkArea => SfSparkAreaChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              marker: marker,
              trackball: trackball,
              labelDisplayMode: definition.options.showDataLabels
                  ? SparkChartLabelDisplayMode.last
                  : SparkChartLabelDisplayMode.none,
            ),
          ChartType.sparkBar => SfSparkBarChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              trackball: trackball,
              labelDisplayMode: definition.options.showDataLabels
                  ? SparkChartLabelDisplayMode.last
                  : SparkChartLabelDisplayMode.none,
            ),
          ChartType.sparkWinLoss => SfSparkWinLossChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              highPointColor: theme.success,
              lowPointColor: theme.danger,
              negativePointColor: theme.danger,
              trackball: trackball,
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

class _NoopListenable extends ChangeNotifier {
  _NoopListenable._();

  static final instance = _NoopListenable._();
}
