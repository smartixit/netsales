import 'package:flutter/material.dart';

import '../enums/dashboard_metric_state.dart';
import '../models/dashboard_metric_data.dart';
import '../theme/dashboard_metrics_theme.dart';
import 'dashboard_metric_content.dart';
import 'dashboard_metric_state_view.dart';

/// A semantic KPI surface: value, interpretation, boundaries and provenance.
class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.metric,
    this.state = DashboardMetricState.data,
    this.emptyMessage,
    this.errorMessage,
    this.retryLabel = 'Retry',
    this.onRetry,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final DashboardMetricData metric;
  final DashboardMetricState state;
  final String? emptyMessage;
  final String? errorMessage;
  final String retryLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardMetricsTheme.of(context);
    final accent = tokens.colorFor(metric.tone);
    final radius = BorderRadius.circular(tokens.cardRadius);

    return Semantics(
      container: true,
      button: onTap != null && state == DashboardMetricState.data,
      label: semanticsLabel ?? _semanticSummary(),
      child: Material(
        color: tokens.cardBackground,
        elevation: 0,
        borderRadius: radius,
        child: InkWell(
          onTap: state == DashboardMetricState.data ? onTap : null,
          borderRadius: radius,
          child: AnimatedContainer(
            duration: tokens.motionDuration,
            curve: tokens.motionCurve,
            padding: EdgeInsets.all(tokens.cardPadding),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: tokens.cardBorder),
              boxShadow: tokens.cardShadows,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 132),
              child: state == DashboardMetricState.data
                  ? DashboardMetricContent(
                      metric: metric,
                      accent: accent,
                      tokens: tokens,
                    )
                  : DashboardMetricStateView(
                      state: state,
                      emptyMessage: emptyMessage ?? 'No metric data available',
                      errorMessage:
                          errorMessage ?? 'Unable to load this metric',
                      retryLabel: retryLabel,
                      onRetry: onRetry,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _semanticSummary() {
    final parts = <String>[metric.title, metric.value];
    final trend = metric.trend;
    if (trend != null) {
      parts.add(trend.valueLabel);
      parts.add(trend.comparisonLabel);
    }
    final source = metric.source;
    if (source != null) {
      parts.add(source.label);
      if (source.updatedAtLabel != null) parts.add(source.updatedAtLabel!);
      if (source.freshnessLabel != null) parts.add(source.freshnessLabel!);
    }
    if (metric.statusLabel != null) parts.add(metric.statusLabel!);
    return parts.join(', ');
  }
}
