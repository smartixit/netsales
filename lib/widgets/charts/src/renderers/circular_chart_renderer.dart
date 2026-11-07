import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

import '../enums/chart_type.dart';
import '../models/chart_data_point.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';
import 'chart_renderer.dart';

class CircularChartRenderer extends StatelessWidget {
  const CircularChartRenderer({
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
    final options = definition.options;

    return SfCircularChart(
      backgroundColor: Colors.transparent,
      palette: theme.palette,
      legend: Legend(
        isVisible: options.showLegend,
        position: options.legendAtBottom
            ? LegendPosition.bottom
            : LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(color: theme.mutedText),
      ),
      tooltipBehavior: TooltipBehavior(enable: options.showTooltip),
      series: definition.series
          .map((series) => _buildSeries(series, theme))
          .toList(growable: false),
    );
  }

  CircularSeries<ChartDataPoint, dynamic> _buildSeries(
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final type = series.resolveType(definition.type);
    final data = series.dataSource;
    final source = series.liveDataSource;
    final labelSettings = DataLabelSettings(
      isVisible: definition.options.showDataLabels,
      textStyle: TextStyle(color: theme.text, fontSize: 11),
    );
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

    void onRendererCreated(CircularSeriesController<ChartDataPoint, dynamic> controller) {
      source?.bindSyncfusion(
        controller.updateDataSource,
        bindingId: '$bindingScope:${series.id}',
      );
    }

    switch (type) {
      case ChartType.pie:
        return PieSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
          name: series.name,
          radius: '82%',
          explode: false,
          dataLabelSettings: labelSettings,
          opacity: series.opacity,
          enableTooltip: definition.options.showTooltip,
          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.doughnut:
        return DoughnutSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
          name: series.name,
          radius: '82%',
          innerRadius: '64%',
          dataLabelSettings: labelSettings,
          opacity: series.opacity,
          enableTooltip: definition.options.showTooltip,
          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.radialBar:
        return RadialBarSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          pointColorMapper: (_, index) => theme.palette[index % theme.palette.length],
          name: series.name,
          radius: '86%',
          innerRadius: '28%',
          dataLabelSettings: labelSettings,
          opacity: series.opacity,
          enableTooltip: definition.options.showTooltip,
          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.line ||
           ChartType.spline ||
           ChartType.fastLine ||
           ChartType.area ||
           ChartType.splineArea ||
           ChartType.stepLine ||
           ChartType.stepArea ||
           ChartType.rangeArea ||
           ChartType.splineRangeArea ||
           ChartType.column ||
           ChartType.bar ||
           ChartType.stackedColumn ||
           ChartType.stackedBar ||
           ChartType.stackedArea ||
           ChartType.stackedLine ||
           ChartType.stackedColumn100 ||
           ChartType.stackedBar100 ||
           ChartType.stackedArea100 ||
           ChartType.stackedLine100 ||
           ChartType.waterfall ||
           ChartType.scatter ||
           ChartType.bubble ||
           ChartType.histogram ||
           ChartType.boxAndWhisker ||
           ChartType.errorBar ||
           ChartType.rangeColumn ||
           ChartType.candle ||
           ChartType.hilo ||
           ChartType.ohlc ||
           ChartType.funnel ||
           ChartType.pyramid ||
           ChartType.sparkLine ||
           ChartType.sparkArea ||
           ChartType.sparkBar ||
           ChartType.sparkWinLoss:
        throw ArgumentError.value(type, 'series.type', 'This chart type is not circular.');
    }
    throw ArgumentError.value(type, 'series.type', 'Unsupported circular chart type.');
  }
}
