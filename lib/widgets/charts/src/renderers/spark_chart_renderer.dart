import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../enums/chart_type.dart';
import '../models/chart_definition.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';

/// Syncfusion Spark renderer.
///
/// Spark widgets consume a numeric list. A single series fills the available
/// plot area; multiple visible series are composed as independently labelled
/// compact charts. Each live series listens only to its own source.
class SparkChartRenderer extends StatelessWidget {
  const SparkChartRenderer({super.key, required this.definition});

  final ChartDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final visibleSeries = definition.series
        .where((series) => series.isVisible)
        .toList(growable: false);

    if (visibleSeries.isEmpty) {
      return const SizedBox.shrink();
    }

    if (visibleSeries.length == 1) {
      return _buildSparkChart(context, visibleSeries.single, theme);
    }

    return Column(
      children: [
        for (final series in visibleSeries)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 104,
                    child: Text(
                      series.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: theme.mutedText,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSparkChart(context, series, theme)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSparkChart(
    BuildContext context,
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final type = series.resolveType(definition.type);
    _ensureSparkType(type);

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
        final labelDisplayMode = definition.options.showDataLabels
            ? SparkChartLabelDisplayMode.last
            : SparkChartLabelDisplayMode.none;

        return switch (type) {
          ChartType.sparkLine => SfSparkLineChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              marker: marker,
              trackball: trackball,
              labelDisplayMode: labelDisplayMode,
            ),
          ChartType.sparkArea => SfSparkAreaChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              marker: marker,
              trackball: trackball,
              labelDisplayMode: labelDisplayMode,
            ),
          ChartType.sparkBar => SfSparkBarChart(
              data: values,
              color: color,
              axisLineWidth: 0,
              trackball: trackball,
              labelDisplayMode: labelDisplayMode,
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
          _ => throw ArgumentError.value(
              type,
              'series.type',
              'Spark family supports only SparkLine, SparkArea, SparkBar, '
                  'and SparkWinLoss chart types.',
            ),
        };
      },
    );
  }

  void _ensureSparkType(ChartType type) {
    const supportedTypes = <ChartType>{
      ChartType.sparkLine,
      ChartType.sparkArea,
      ChartType.sparkBar,
      ChartType.sparkWinLoss,
    };
    if (!supportedTypes.contains(type)) {
      throw ArgumentError.value(
        type,
        'series.type',
        'Spark family supports only SparkLine, SparkArea, SparkBar, '
            'and SparkWinLoss chart types.',
      );
    }
  }
}

class _NoopListenable extends ChangeNotifier {
  _NoopListenable._();

  static final instance = _NoopListenable._();
}
