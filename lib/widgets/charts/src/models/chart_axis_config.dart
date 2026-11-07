import 'package:flutter/foundation.dart';

import '../enums/chart_axis_kind.dart';

@immutable
class ChartAxisConfig {
  const ChartAxisConfig({
    this.kind = ChartAxisKind.category,
    this.name,
    this.title,
    this.minimum,
    this.maximum,
    this.interval,
    this.labelRotation = 0,
    this.isVisible = true,
    this.isInversed = false,
    this.opposedPosition = false,
    this.labelFormat,
  });

  final ChartAxisKind kind;
  final String? name;
  final String? title;
  final num? minimum;
  final num? maximum;
  final num? interval;
  final double labelRotation;
  final bool isVisible;
  final bool isInversed;
  final bool opposedPosition;
  final String? labelFormat;
}
