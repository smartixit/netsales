import 'package:flutter/foundation.dart';

enum DashboardMetricFreshness {
  fresh,
  stale,
  unknown,
}

/// Provenance and freshness metadata for the displayed value.
@immutable
class DashboardMetricSource {
  const DashboardMetricSource({
    required this.label,
    this.detail,
    this.updatedAt,
    this.updatedAtLabel,
    this.freshnessLabel,
    this.freshness = DashboardMetricFreshness.unknown,
  }) : assert(label != '');

  /// Human-readable origin, e.g. "Platform reporting service".
  final String label;
  final String? detail;
  final DateTime? updatedAt;

  /// Localized display text supplied by the host.
  final String? updatedAtLabel;
  final String? freshnessLabel;
  final DashboardMetricFreshness freshness;
}
