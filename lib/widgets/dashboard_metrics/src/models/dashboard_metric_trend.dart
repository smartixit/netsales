import '../enums/dashboard_metric_direction.dart';
import '../enums/dashboard_metric_tone.dart';

/// A server- or domain-interpreted comparison. This model deliberately does
/// not calculate percentage changes or decide whether an increase is good.
class DashboardMetricTrend {
  const DashboardMetricTrend({
    required this.direction,
    required this.tone,
    required this.valueLabel,
    required this.comparisonLabel,
    this.description,
  }) : assert(valueLabel != '');

  final DashboardMetricDirection direction;
  final DashboardMetricTone tone;

  /// Already formatted by the host, e.g. "+12.5%" or "−3.2%".
  final String valueLabel;

  /// Explicit context, e.g. "Compared with the previous 30 days".
  final String comparisonLabel;

  final String? description;
}
