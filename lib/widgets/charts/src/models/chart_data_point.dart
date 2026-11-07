import 'package:flutter/foundation.dart';

/// Neutral point contract consumed by every chart family.
///
/// [x] can be a category, number, or DateTime. Financial and range charts use
/// [low], [high], [open], and [close]. Distribution charts can use [samples].
@immutable
class ChartDataPoint {
  const ChartDataPoint({
    required this.x,
    this.y,
    this.low,
    this.high,
    this.open,
    this.close,
    this.volume,
    this.size,
    this.samples,
    this.isIntermediateSum = false,
    this.isTotalSum = false,
    this.label,
  });

  final Object? x;
  final num? y;
  final num? low;
  final num? high;
  final num? open;
  final num? close;
  final num? volume;
  final num? size;
  final List<num>? samples;
  final bool isIntermediateSum;
  final bool isTotalSum;
  final String? label;
}
