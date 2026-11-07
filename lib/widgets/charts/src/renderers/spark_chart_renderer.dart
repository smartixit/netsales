import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../enums/chart_type.dart';
import '../enums/chart_state.dart';
import '../models/chart_definition.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';
import '../widgets/chart_state_view.dart';

class SparkChartRenderer extends StatelessWidget {
  const SparkChartRenderer({super.key, required this.definition});

  final ChartDefinition definition;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final visibleSeries = definition.series
        .where((series) => series.isVisible)
        .toList(growable: false);
    final liveSources = visibleSeries
        .map((series) => series.liveDataSource)
        .whereType<Listenable>()
        .toList(growable: false);

    return AnimatedBuilder(
      animation: Listenable.merge(liveSources),
      builder: (context, _) {
        final populatedSeries = visibleSeries
            .where((series) => series.dataSource.isNotEmpty)
            .toList(growable: false);

        if (populatedSeries.isEmpty) {
          return const ChartStateView(state: ChartState.empty);
        }

        if (populatedSeries.length == 1) {
          return _buildSparkChart(context, populatedSeries.single, theme);
        }

        return Column(
          children: [
            for (final series in populatedSeries)
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
      },
    );
  }

  Widget _buildSparkChart(
    BuildContext context,
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final type = series.resolveType(definition.type);
    _ensureSparkType(type);
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
