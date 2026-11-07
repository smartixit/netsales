import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../enums/chart_type.dart';
import '../models/chart_data_point.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';
import 'chart_renderer.dart';

class FunnelChartRenderer extends StatelessWidget {
  const FunnelChartRenderer({
    super.key,
    required this.definition,
    required this.bindingScope,
    this.onPointTap,
  });

  final ChartDefinition definition;
  final String bindingScope;
  final ValueChanged<ChartPointInteraction>? onPointTap;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final type = definition.type;
    if (type == ChartType.funnel) {
      return SfFunnelChart(
        backgroundColor: Colors.transparent,
        palette: theme.palette,
        legend: Legend(
          isVisible: definition.options.showLegend,
          position: definition.options.legendAtBottom
              ? LegendPosition.bottom
              : LegendPosition.right,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(color: theme.mutedText),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: definition.options.showTooltip,
        ),
        series: definition.series
            .map((series) => _buildFunnelSeries(series, theme))
            .toList(growable: false),
      );
    }

    if (type == ChartType.pyramid) {
      return SfPyramidChart(
        backgroundColor: Colors.transparent,
        palette: theme.palette,
        legend: Legend(
          isVisible: definition.options.showLegend,
          position: definition.options.legendAtBottom
              ? LegendPosition.bottom
              : LegendPosition.right,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: TextStyle(color: theme.mutedText),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: definition.options.showTooltip,
        ),
        series: definition.series
            .map((series) => _buildPyramidSeries(series, theme))
            .toList(growable: false),
      );
    }

    throw ArgumentError.value(
      type,
      'definition.type',
      'Funnel family supports only Funnel and Pyramid chart types.',
    );
  }

  FunnelSeries<ChartDataPoint, dynamic> _buildFunnelSeries(
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final source = series.liveDataSource;
    final pointTap = onPointTap == null
        ? null
        : (ChartPointDetails details) {
            final interaction = resolveChartPointInteraction(
              series: definition.series,
              seriesIndex: details.seriesIndex,
              pointIndex: details.pointIndex,
            );
            if (interaction != null) {
              onPointTap!(interaction);
            }
          };

    return FunnelSeries<ChartDataPoint, dynamic>(
      dataSource: series.dataSource,
      xValueMapper: (point, index) => point.x ?? index,
      yValueMapper: (point, _) => point.y ?? 0,
      pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
      name: series.name,
      opacity: series.opacity,
      dataLabelSettings: DataLabelSettings(
        isVisible: definition.options.showDataLabels,
        textStyle: TextStyle(color: theme.text, fontSize: 11),
      ),
      onRendererCreated: (FunnelSeriesController controller) {
        source?.bindSyncfusion(
          controller.updateDataSource,
          bindingId: '$bindingScope:${series.id}',
        );
      },
      onPointTap: pointTap,
    );
  }

  PyramidSeries<ChartDataPoint, dynamic> _buildPyramidSeries(
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final source = series.liveDataSource;
    final pointTap = onPointTap == null
        ? null
        : (ChartPointDetails details) {
            final interaction = resolveChartPointInteraction(
              series: definition.series,
              seriesIndex: details.seriesIndex,
              pointIndex: details.pointIndex,
            );
            if (interaction != null) {
              onPointTap!(interaction);
            }
          };

    return PyramidSeries<ChartDataPoint, dynamic>(
      dataSource: series.dataSource,
      xValueMapper: (point, index) => point.x ?? index,
      yValueMapper: (point, _) => point.y ?? 0,
      pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
      name: series.name,
      opacity: series.opacity,
      dataLabelSettings: DataLabelSettings(
        isVisible: definition.options.showDataLabels,
        textStyle: TextStyle(color: theme.text, fontSize: 11),
      ),
      onRendererCreated: (PyramidSeriesController controller) {
        source?.bindSyncfusion(
          controller.updateDataSource,
          bindingId: '$bindingScope:${series.id}',
        );
      },
      onPointTap: pointTap,
    );
  }
}
