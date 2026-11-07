import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

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
    if (definition.series.length != 1) {
      throw ArgumentError.value(
        definition.series.length,
        'definition.series.length',
        'Syncfusion Funnel and Pyramid charts accept exactly one series.',
      );
    }
    final series = definition.series.single;
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
          toggleSeriesVisibility: definition.options.toggleSeriesVisibility,
          textStyle: TextStyle(color: theme.mutedText),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: definition.options.showTooltip,
        ),
        series: _buildFunnelSeries(series, theme),
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
          toggleSeriesVisibility: definition.options.toggleSeriesVisibility,
          textStyle: TextStyle(color: theme.mutedText),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: definition.options.showTooltip,
        ),
        series: _buildPyramidSeries(series, theme),
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
      animationDuration: definition.options.animate
          ? definition.options.animationDuration.toDouble()
          : 0,
      xValueMapper: (point, index) => point.x ?? index,
      yValueMapper: (point, _) => point.y ?? 0,
      pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
      name: series.name,
      opacity: series.opacity,
      dataLabelSettings: DataLabelSettings(
        isVisible: definition.options.showDataLabels,
        textStyle: TextStyle(color: theme.text, fontSize: 11),
      ),
      onRendererCreated: (FunnelSeriesController<ChartDataPoint, dynamic> controller) {
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
      animationDuration: definition.options.animate
          ? definition.options.animationDuration.toDouble()
          : 0,
      xValueMapper: (point, index) => point.x ?? index,
      yValueMapper: (point, _) => point.y ?? 0,
      pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
      name: series.name,
      opacity: series.opacity,
      dataLabelSettings: DataLabelSettings(
        isVisible: definition.options.showDataLabels,
        textStyle: TextStyle(color: theme.text, fontSize: 11),
      ),
      onRendererCreated: (PyramidSeriesController<ChartDataPoint, dynamic> controller) {
        source?.bindSyncfusion(
          controller.updateDataSource,
          bindingId: '$bindingScope:${series.id}',
        );
      },
      onPointTap: pointTap,
    );
  }
}
