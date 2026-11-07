import 'package:flutter/material.dart';

enum ChartTrendlineType {
  linear,
  exponential,
  logarithmic,
  polynomial,
  power,
  movingAverage,
}

@immutable
class ChartTrendlineConfig {
  const ChartTrendlineConfig({
    this.type = ChartTrendlineType.linear,
    this.name,
    this.color,
    this.width = 2,
    this.opacity = 0.9,
    this.forwardForecast = 0,
    this.backwardForecast = 0,
    this.period = 2,
    this.polynomialOrder = 2,
    this.animationDuration = 650,
    this.animationDelay = 0,
    this.valueField = 'high',
    this.dashArray,
    this.isVisible = true,
    this.isVisibleInLegend = true,
    this.enableTooltip = true,
  }) : assert(width >= 0),
       assert(opacity >= 0 && opacity <= 1),
       assert(forwardForecast >= 0),
       assert(backwardForecast >= 0),
       assert(period >= 1),
       assert(polynomialOrder >= 1),
       assert(animationDuration >= 0),
       assert(animationDelay >= 0);

  final ChartTrendlineType type;
  final String? name;
  final Color? color;
  final double width;
  final double opacity;
  final double forwardForecast;
  final double backwardForecast;
  final int period;
  final int polynomialOrder;
  final double animationDuration;
  final double animationDelay;
  final String valueField;
  final List<double>? dashArray;
  final bool isVisible;
  final bool isVisibleInLegend;
  final bool enableTooltip;
}
