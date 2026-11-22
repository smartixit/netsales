import 'package:flutter/material.dart';

import '../enums/dashboard_metric_state.dart';

/// Localizable non-data presentations for a KPI card.
class DashboardMetricStateView extends StatelessWidget {
  const DashboardMetricStateView({
    required this.state,
    required this.emptyMessage,
    required this.errorMessage,
    required this.retryLabel,
    this.onRetry,
    super.key,
  });

  final DashboardMetricState state;
  final String emptyMessage;
  final String errorMessage;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      DashboardMetricState.loading => const _MetricSkeleton(),
      DashboardMetricState.empty => _StateMessage(
        icon: Icons.query_stats_rounded,
        message: emptyMessage,
      ),
      DashboardMetricState.error => _ErrorMessage(
        message: errorMessage,
        retryLabel: retryLabel,
        onRetry: onRetry,
      ),
      DashboardMetricState.data => const SizedBox.shrink(),
    };
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({
    required this.message,
    required this.retryLabel,
    this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(retryLabel),
          ),
        ],
      ],
    ),
  );
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SkeletonBlock(width: 75, height: 12, color: color),
            _SkeletonBlock(width: 24, height: 24, color: color, radius: 8),
          ],
        ),
        const SizedBox(height: 10),
        _SkeletonBlock(width: 100, height: 20, color: color),
        const SizedBox(height: 8),
        _SkeletonBlock(width: 60, height: 10, color: color),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
    this.radius = 6,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
