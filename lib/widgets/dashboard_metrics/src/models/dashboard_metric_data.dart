import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../enums/dashboard_metric_tone.dart';
import '../enums/dashboard_metric_variant.dart';
import 'dashboard_metric_source.dart';
import 'dashboard_metric_threshold.dart';
import 'dashboard_metric_trend.dart';

/// Immutable, display-ready KPI contract.
///
/// [value] and every label are formatted by the host application. This keeps
/// localization, currency formatting, rounding, and business semantics out
/// of a generic presentation widget.
@immutable
class DashboardMetricData {
  const DashboardMetricData({
    required this.id,
    required this.title,
    required this.value,
    required this.variant,
    this.description,
    this.unit,
    this.icon,
    this.tone = DashboardMetricTone.primary,
    this.trend,
    this.sparkline = const [],
    this.target,
    this.source,
    this.tooltip,
    this.statusLabel,
  }) : assert(id != ''),
       assert(title != ''),
       assert(value != ''),
       assert(sparkline.length == 0 || sparkline.length >= 2),
       assert(sparkline.every((point) => point >= 0 && point <= 1)),
       assert(variant != DashboardMetricVariant.target || target != null),
       assert(variant != DashboardMetricVariant.status || statusLabel != null);

  final String id;
  final String title;

  /// Display-ready value. Never pass a value that this widget must calculate.
  final String value;
  final String? unit;
  final String? description;
  final IconData? icon;
  final DashboardMetricTone tone;
  final DashboardMetricVariant variant;
  final DashboardMetricTrend? trend;

  /// Normalized 0..1 points in chronological order.
  final List<double> sparkline;
  final DashboardMetricTarget? target;
  final DashboardMetricSource? source;
  final String? tooltip;

  /// Localized status caption supplied by the host for status cards.
  final String? statusLabel;
}
