import 'package:flutter/foundation.dart';

/// Statistical rule used to calculate the error-bar extent.
enum ChartErrorBarType {
  fixed,
  percentage,
  standardDeviation,
  standardError,
  custom,
}

/// Axis direction in which the error bar is drawn.
enum ChartErrorBarMode {
  vertical,
  horizontal,
  both,
}

/// Neutral error-bar options mapped to Syncfusion's ErrorBarSeries properties.
@immutable
class ChartErrorBarConfig {
  const ChartErrorBarConfig({
    this.type = ChartErrorBarType.fixed,
    this.mode = ChartErrorBarMode.vertical,
    this.verticalErrorValue = 3,
    this.horizontalErrorValue = 1,
    this.verticalPositiveErrorValue = 3,
    this.verticalNegativeErrorValue = 3,
    this.horizontalPositiveErrorValue = 1,
    this.horizontalNegativeErrorValue = 1,
    this.capLength = 10,
  }) : assert(verticalErrorValue >= 0),
       assert(horizontalErrorValue >= 0),
       assert(verticalPositiveErrorValue >= 0),
       assert(verticalNegativeErrorValue >= 0),
       assert(horizontalPositiveErrorValue >= 0),
       assert(horizontalNegativeErrorValue >= 0),
       assert(capLength >= 0);

  final ChartErrorBarType type;
  final ChartErrorBarMode mode;
  final double verticalErrorValue;
  final double horizontalErrorValue;
  final double verticalPositiveErrorValue;
  final double verticalNegativeErrorValue;
  final double horizontalPositiveErrorValue;
  final double horizontalNegativeErrorValue;
  final double capLength;
}
