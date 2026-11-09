import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart' hide ChartSeries;

import '../enums/chart_axis_kind.dart';
import '../enums/chart_type.dart';
import '../models/chart_axis_config.dart';
import '../models/chart_plot_band_config.dart';
import '../models/chart_trendline_config.dart';
import '../models/chart_data_point.dart';
import '../models/chart_error_bar_config.dart';
import '../models/chart_definition.dart';
import '../models/chart_interaction.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';
import 'chart_renderer.dart';

class CartesianChartRenderer extends StatelessWidget {
  const CartesianChartRenderer({
    super.key,
    required this.definition,
    required this.bindingScope,
    required this.zoomPanBehavior,
    this.onPointTap,
  });

  final ChartDefinition definition;
  final String bindingScope;
  final ZoomPanBehavior? zoomPanBehavior;
  final ValueChanged<ChartPointInteraction>? onPointTap;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final options = definition.options;

    return SfCartesianChart(
      margin: const EdgeInsets.fromLTRB(4, 10, 8, 4),
      backgroundColor: Colors.transparent,
      plotAreaBackgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      isTransposed: options.isTransposed,
      palette: theme.palette,
      primaryXAxis: _buildAxis(
        options.xAxis,
        theme,
        options.showMajorGridLines,
        autoScrollingDelta: options.autoScrollingDelta,
      ),
      primaryYAxis: _buildAxis(
        options.yAxis,
        theme,
        options.showMajorGridLines,
      ),
      axes: options.additionalAxes
          .map((axis) => _buildAxis(axis, theme, options.showMajorGridLines))
          .toList(growable: false),
      legend: Legend(
        isVisible: options.showLegend,
        position: options.legendAtBottom
            ? LegendPosition.bottom
            : LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
        toggleSeriesVisibility: options.toggleSeriesVisibility,
        textStyle: TextStyle(color: theme.mutedText),
      ),
      tooltipBehavior: TooltipBehavior(enable: options.showTooltip),
      trackballBehavior: options.enableTrackball
          ? TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipSettings: InteractiveTooltip(enable: true),
            )
          : null,
      crosshairBehavior: options.enableCrosshair
          ? CrosshairBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
            )
          : null,
      zoomPanBehavior: zoomPanBehavior,
      series: definition.series
          .map((series) => _buildSeries(series, theme))
          .toList(growable: false),
    );
  }

  List<PlotBand> _buildPlotBands(
    List<ChartPlotBandConfig> configs,
    ChartsTheme theme,
  ) => configs
      .map(
        (band) => PlotBand(
          isVisible: band.isVisible,
          start: band.start,
          end: band.end,
          associatedAxisStart: band.associatedAxisStart,
          associatedAxisEnd: band.associatedAxisEnd,
          color: band.color,
          opacity: band.opacity,
          borderColor: band.borderColor,
          borderWidth: band.borderWidth,
          dashArray: band.dashArray,
          text: band.text,
          textStyle: band.text == null
              ? null
              : TextStyle(
                  color: band.textColor ?? theme.text,
                  fontSize: band.textFontSize,
                ),
          shouldRenderAboveSeries: band.shouldRenderAboveSeries,
        ),
      )
      .toList(growable: false);

  List<Trendline>? _buildTrendlines(
    ChartSeries series,
    ChartType type,
    ChartsTheme theme,
  ) {
    if (series.trendlines.isEmpty) return null;
    if (type == ChartType.bar ||
        type == ChartType.stackedBar ||
        type == ChartType.stackedBar100) {
      throw ArgumentError.value(
        type,
        'series.type',
        'Syncfusion trendlines are not supported by horizontal bar series.',
      );
    }

    return series.trendlines
        .map(
          (config) => Trendline(
            type: switch (config.type) {
              ChartTrendlineType.linear => TrendlineType.linear,
              ChartTrendlineType.exponential => TrendlineType.exponential,
              ChartTrendlineType.logarithmic => TrendlineType.logarithmic,
              ChartTrendlineType.polynomial => TrendlineType.polynomial,
              ChartTrendlineType.power => TrendlineType.power,
              ChartTrendlineType.movingAverage => TrendlineType.movingAverage,
            },
            name: config.name,
            color: config.color ?? theme.palette.first,
            width: config.width,
            opacity: config.opacity,
            forwardForecast: config.forwardForecast,
            backwardForecast: config.backwardForecast,
            period: config.period,
            polynomialOrder: config.polynomialOrder,
            animationDuration: config.animationDuration,
            animationDelay: config.animationDelay,
            valueField: config.valueField,
            dashArray: config.dashArray,
            isVisible: config.isVisible,
            isVisibleInLegend: config.isVisibleInLegend,
            enableTooltip: config.enableTooltip,
          ),
        )
        .toList(growable: false);
  }

  ChartAxis _buildAxis(
    ChartAxisConfig config,
    ChartsTheme theme,
    bool showGrid, {
    int? autoScrollingDelta,
  }) {
    final title = AxisTitle(
      text: config.title ?? '',
      textStyle: TextStyle(color: theme.mutedText, fontSize: 11),
    );
    final labelStyle = TextStyle(
      color: theme.mutedText,
      fontSize: theme.axisLabelSize,
    );
    final axisLine = const AxisLine(width: 0);
    final majorGridLines = MajorGridLines(
      width: showGrid ? 0.7 : 0,
      color: theme.gridLine,
    );

    return switch (config.kind) {
      ChartAxisKind.category => CategoryAxis(
        name: config.name,
        title: title,
        axisLabelFormatter: config.labelFormat == null
            ? null
            : (details) => ChartAxisLabel(
                config.labelFormat!.replaceAll('{value}', details.text),
                details.textStyle,
              ),
        labelStyle: labelStyle,
        labelRotation: config.labelRotation,
        isVisible: config.isVisible,
        isInversed: config.isInversed,
        opposedPosition: config.opposedPosition,
        axisLine: axisLine,
        majorGridLines: majorGridLines,

        plotBands: _buildPlotBands(config.plotBands, theme),
        autoScrollingDelta: autoScrollingDelta,
      ),
      ChartAxisKind.numeric => NumericAxis(
        name: config.name,
        title: title,
        labelFormat: config.labelFormat,
        labelStyle: labelStyle,
        minimum: config.minimum?.toDouble(),
        maximum: config.maximum?.toDouble(),
        interval: config.interval?.toDouble(),
        labelRotation: config.labelRotation,
        isVisible: config.isVisible,
        isInversed: config.isInversed,
        opposedPosition: config.opposedPosition,
        axisLine: axisLine,
        majorGridLines: majorGridLines,

        plotBands: _buildPlotBands(config.plotBands, theme),
        autoScrollingDelta: autoScrollingDelta,
      ),
      ChartAxisKind.dateTime => DateTimeAxis(
        name: config.name,
        title: title,
        labelFormat: config.labelFormat,
        labelStyle: labelStyle,
        labelRotation: config.labelRotation,
        isVisible: config.isVisible,
        isInversed: config.isInversed,
        opposedPosition: config.opposedPosition,
        axisLine: axisLine,
        majorGridLines: majorGridLines,

        plotBands: _buildPlotBands(config.plotBands, theme),
        autoScrollingDelta: autoScrollingDelta,
      ),
      ChartAxisKind.dateTimeCategory => DateTimeCategoryAxis(
        name: config.name,
        title: title,
        axisLabelFormatter: config.labelFormat == null
            ? null
            : (details) => ChartAxisLabel(
                config.labelFormat!.replaceAll('{value}', details.text),
                details.textStyle,
              ),
        labelStyle: labelStyle,
        labelRotation: config.labelRotation,
        isVisible: config.isVisible,
        isInversed: config.isInversed,
        opposedPosition: config.opposedPosition,
        axisLine: axisLine,
        majorGridLines: majorGridLines,

        plotBands: _buildPlotBands(config.plotBands, theme),
        autoScrollingDelta: autoScrollingDelta,
      ),
      ChartAxisKind.logarithmic => LogarithmicAxis(
        name: config.name,
        title: title,
        labelFormat: config.labelFormat,
        labelStyle: labelStyle,
        minimum: config.minimum?.toDouble(),
        maximum: config.maximum?.toDouble(),
        interval: config.interval?.toDouble(),
        labelRotation: config.labelRotation,
        isVisible: config.isVisible,
        isInversed: config.isInversed,
        opposedPosition: config.opposedPosition,
        axisLine: axisLine,
        majorGridLines: majorGridLines,

        plotBands: _buildPlotBands(config.plotBands, theme),
        autoScrollingDelta: autoScrollingDelta,
      ),
    };
  }

  CartesianSeries<ChartDataPoint, dynamic> _buildSeries(
    ChartSeries series,
    ChartsTheme theme,
  ) {
    final type = series.resolveType(definition.type);
    final data = series.dataSource;
    final color = series.color ?? theme.palette.first;
    final source = series.liveDataSource;
    final onRendererCreated = source == null
        ? null
        : (ChartSeriesController<ChartDataPoint, dynamic> controller) {
            source.bindSyncfusion(
              controller.updateDataSource,
              bindingId: '$bindingScope:${series.id}',
            );
          };
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
    final labels = DataLabelSettings(
      isVisible: definition.options.showDataLabels,
      textStyle: TextStyle(color: theme.text, fontSize: 10),
    );
    final trendlines = _buildTrendlines(series, type, theme);
    final marker = MarkerSettings(
      isVisible: definition.options.showMarkers,
      height: 7,
      width: 7,
      borderColor: theme.cardSurface,
      borderWidth: 1.5,
    );
    switch (type) {
      case ChartType.line:
        return LineSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.spline:
        return SplineSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.fastLine:
        return FastLineSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.area:
        return AreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.splineArea:
        return SplineAreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stepLine:
        return StepLineSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stepArea:
        return StepAreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.rangeArea:
        return RangeAreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.splineRangeArea:
        return SplineRangeAreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.column:
        return ColumnSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderRadius: BorderRadius.circular(5),
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.bar:
        return BarSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderRadius: BorderRadius.circular(5),
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedColumn:
        return StackedColumnSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderRadius: BorderRadius.circular(4),
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedBar:
        return StackedBarSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderRadius: BorderRadius.circular(4),
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedArea:
        return StackedAreaSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          borderWidth: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedLine:
        return StackedLineSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedColumn100:
        return StackedColumn100Series<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedBar100:
        return StackedBar100Series<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedArea100:
        return StackedArea100Series<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.stackedLine100:
        return StackedLine100Series<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          groupName: series.stackGroup ?? 'default',
          color: color,
          opacity: series.opacity,
          width: series.strokeWidth,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.waterfall:
        return WaterfallSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          intermediateSumColor: theme.warning,
          totalSumColor: theme.success,
          intermediateSumPredicate: (point, _) => point.isIntermediateSum,
          totalSumPredicate: (point, _) => point.isTotalSum,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.scatter:
        return ScatterSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          markerSettings: marker,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.bubble:
        return BubbleSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          sizeValueMapper: (point, _) => point.size ?? 1,
          name: series.name,
          color: color,
          opacity: series.opacity,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.histogram:
        return HistogramSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          yValueMapper: (point, _) => point.y ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          binInterval: series.binInterval,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.boxAndWhisker:
        return BoxAndWhiskerSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.samples ?? const <num>[],
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderWidth: series.strokeWidth,
          showMean: definition.options.showMeanInBoxPlot,
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.errorBar:
        return ErrorBarSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          yValueMapper: (point, _) => point.y ?? 0,
          type: switch (definition.options.errorBar.type) {
            ChartErrorBarType.fixed => ErrorBarType.fixed,
            ChartErrorBarType.percentage => ErrorBarType.percentage,
            ChartErrorBarType.standardDeviation =>
              ErrorBarType.standardDeviation,
            ChartErrorBarType.standardError => ErrorBarType.standardError,
            ChartErrorBarType.custom => ErrorBarType.custom,
          },
          mode: switch (definition.options.errorBar.mode) {
            ChartErrorBarMode.vertical => RenderingMode.vertical,
            ChartErrorBarMode.horizontal => RenderingMode.horizontal,
            ChartErrorBarMode.both => RenderingMode.both,
          },
          verticalErrorValue: definition.options.errorBar.verticalErrorValue,
          horizontalErrorValue:
              definition.options.errorBar.horizontalErrorValue,
          verticalPositiveErrorValue:
              definition.options.errorBar.verticalPositiveErrorValue,
          verticalNegativeErrorValue:
              definition.options.errorBar.verticalNegativeErrorValue,
          horizontalPositiveErrorValue:
              definition.options.errorBar.horizontalPositiveErrorValue,
          horizontalNegativeErrorValue:
              definition.options.errorBar.horizontalNegativeErrorValue,
          capLength: definition.options.errorBar.capLength,
          name: series.name,
          color: color,
          width: series.strokeWidth,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,

          onRendererCreated: onRendererCreated,
        );
      case ChartType.rangeColumn:
        return RangeColumnSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          width: series.seriesWidth,
          borderRadius: BorderRadius.circular(4),
          dataLabelSettings: labels,
          initialIsVisible: series.isVisible,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.candle:
        return CandleSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          openValueMapper: (point, _) => point.open ?? 0,
          closeValueMapper: (point, _) => point.close ?? 0,
          name: series.name,
          bullColor: theme.success,
          bearColor: theme.danger,
          enableSolidCandles: definition.options.solidCandles,
          width: series.seriesWidth,
          opacity: series.opacity,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.hilo:
        return HiloSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          name: series.name,
          color: color,
          opacity: series.opacity,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.ohlc:
        return HiloOpenCloseSeries<ChartDataPoint, dynamic>(
          dataSource: data,
          animationDuration: definition.options.animate
              ? definition.options.animationDuration.toDouble()
              : 0,
          xValueMapper: (point, index) => point.x ?? index,
          lowValueMapper: (point, _) => point.low ?? 0,
          highValueMapper: (point, _) => point.high ?? 0,
          openValueMapper: (point, _) => point.open ?? 0,
          closeValueMapper: (point, _) => point.close ?? 0,
          volumeValueMapper: (point, _) => point.volume,
          name: series.name,
          bullColor: theme.success,
          bearColor: theme.danger,
          borderWidth: series.strokeWidth,
          opacity: series.opacity,
          isVisibleInLegend: series.isVisibleInLegend,
          xAxisName: series.xAxisName,
          yAxisName: series.yAxisName,
          enableTooltip: definition.options.showTooltip,
          enableTrackball: definition.options.enableTrackball,
          trendlines: trendlines,

          onRendererCreated: onRendererCreated,
          onPointTap: pointTap,
        );
      case ChartType.pie ||
          ChartType.doughnut ||
          ChartType.radialBar ||
          ChartType.funnel ||
          ChartType.pyramid ||
          ChartType.sparkLine ||
          ChartType.sparkArea ||
          ChartType.sparkBar ||
          ChartType.sparkWinLoss:
        throw ArgumentError.value(
          type,
          'series.type',
          'This chart type is not Cartesian.',
        );
    }
  }
}
