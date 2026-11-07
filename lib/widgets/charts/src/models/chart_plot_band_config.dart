import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class ChartPlotBandConfig {
  const ChartPlotBandConfig({
    required this.start,
    this.end,
    this.associatedAxisStart,
    this.associatedAxisEnd,
    this.color = Colors.transparent,
    this.opacity = 0.12,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.dashArray = const <double>[0, 0],
    this.text,
    this.textColor,
    this.textFontSize = 10,
    this.isVisible = true,
    this.shouldRenderAboveSeries = false,
  }) : assert(opacity >= 0 && opacity <= 1),
       assert(borderWidth >= 0),
       assert(textFontSize > 0);

  const ChartPlotBandConfig.referenceLine({
    required Object value,
    Color color = Colors.transparent,
    Color borderColor = const Color(0xFF0D7A5F),
    double borderWidth = 1.5,
    List<double> dashArray = const <double>[4, 3],
    String? text,
    Color? textColor,
    double textFontSize = 10,
    bool isVisible = true,
    bool shouldRenderAboveSeries = true,
  }) : this(
         start: value,
         end: value,
         color: color,
         opacity: 0,
         borderColor: borderColor,
         borderWidth: borderWidth,
         dashArray: dashArray,
         text: text,
         textColor: textColor,
         textFontSize: textFontSize,
         isVisible: isVisible,
         shouldRenderAboveSeries: shouldRenderAboveSeries,
       );

  final Object start;
  final Object? end;
  final Object? associatedAxisStart;
  final Object? associatedAxisEnd;
  final Color color;
  final double opacity;
  final Color borderColor;
  final double borderWidth;
  final List<double> dashArray;
  final String? text;
  final Color? textColor;
  final double textFontSize;
  final bool isVisible;
  final bool shouldRenderAboveSeries;
}
