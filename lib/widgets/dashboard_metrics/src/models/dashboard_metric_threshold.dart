import 'package:flutter/foundation.dart';

import '../enums/dashboard_metric_tone.dart';

/// A visual boundary on a normalized 0..1 scale.
///
/// The host owns domain interpretation and supplies normalized positions.
/// The widget only renders these boundaries; it never evaluates business
/// thresholds or derives financial/operational status from raw values.
@immutable
class DashboardMetricThreshold {
  const DashboardMetricThreshold({
    required this.position,
    required this.label,
    required this.tone,
  }) : assert(position >= 0 && position <= 1),
       assert(label != '');

  final double position;
  final String label;
  final DashboardMetricTone tone;
}

/// Progress and threshold metadata for target/range KPI variants.
@immutable
class DashboardMetricTarget {
  const DashboardMetricTarget({
    required this.progress,
    required this.currentLabel,
    required this.targetLabel,
    this.label,
    this.thresholds = const [],
  }) : assert(progress >= 0 && progress <= 1),
       assert(currentLabel != ''),
       assert(targetLabel != '');

  /// Normalized progress supplied by the host (not calculated by the widget).
  final double progress;
  final String currentLabel;
  final String targetLabel;
  final String? label;
  final List<DashboardMetricThreshold> thresholds;
}
