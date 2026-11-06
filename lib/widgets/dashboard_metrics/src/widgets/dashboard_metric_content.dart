class DashboardMetricContent extends StatelessWidget {
  const DashboardMetricContent({
    required this.metric,
    required this.accent,
    required this.tokens,
  });

  final DashboardMetricData metric;
  final Color accent;
  final DashboardMetricsTheme tokens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final showTrend = metric.trend != null;
    final showSparkline = metric.sparkline.length >= 2 &&
        metric.variant == DashboardMetricVariant.trend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                metric.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (metric.icon != null) ...[
              const SizedBox(width: 10),
              Tooltip(
                message: metric.tooltip ?? metric.title,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(tokens.iconRadius),
                  ),
                  alignment: Alignment.center,
                  child: Icon(metric.icon, size: 20, color: accent),
                ),
              ),
            ] else if (metric.tooltip != null) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: metric.tooltip!,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: tokens.mutedForeground,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  metric.value,
                  maxLines: 1,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: scheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            if (metric.unit != null) ...[
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  metric.unit!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (metric.description != null) ...[
          const SizedBox(height: 5),
          Text(
            metric.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: tokens.mutedForeground,
            ),
          ),
        ],
        if (showTrend) ...[
          const SizedBox(height: 12),
          _TrendLine(trend: metric.trend!, tokens: tokens),
        ],
        if (showSparkline) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            width: double.infinity,
            child: DashboardMetricSparkline(
              points: metric.sparkline,
              color: accent,
              fillColor: accent.withValues(alpha: 0.10),
            ),
          ),
        ],
        if (metric.variant == DashboardMetricVariant.target &&
            metric.target != null) ...[
          const SizedBox(height: 14),
          _TargetProgress(target: metric.target!, tokens: tokens),
        ],
        if (metric.variant == DashboardMetricVariant.status) ...[
          const SizedBox(height: 10),
          _StatusCaption(
            tone: metric.tone,
            tokens: tokens,
            label: metric.statusLabel,
          ),
        ],
        if (metric.source != null) ...[
          const SizedBox(height: 12),
          _SourceLine(source: metric.source!, tokens: tokens),
        ],
      ],
    );
  }
}

class _TrendLine extends StatelessWidget {
  const _TrendLine({required this.trend, required this.tokens});

  final DashboardMetricTrend trend;
  final DashboardMetricsTheme tokens;

  @override
  Widget build(BuildContext context) {
    final tone = trend.tone;
    final direction = trend.direction;
    final color = tokens.colorFor(tone);
    final icon = switch (direction) {
      DashboardMetricDirection.increase => Icons.trending_up_rounded,
      DashboardMetricDirection.decrease => Icons.trending_down_rounded,
      DashboardMetricDirection.unchanged => Icons.trending_flat_rounded,
    };

    return Wrap(
      spacing: 7,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(icon, size: 17, color: color),
        Text(
          trend.valueLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          trend.comparisonLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: tokens.mutedForeground,
          ),
        ),
        if (trend.description != null)
          Text(
            trend.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.mutedForeground,
            ),
          ),
      ],
    );
  }
}

class _TargetProgress extends StatelessWidget {
  const _TargetProgress({required this.target, required this.tokens});

  final DashboardMetricTarget target;
  final DashboardMetricsTheme tokens;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final markerWidgets = target.thresholds.map((threshold) {
      return Positioned.fill(
        child: Align(
          alignment: AlignmentDirectional(
            -1 + (2 * threshold.position),
            0,
          ),
          child: Tooltip(
            message: threshold.label,
            child: Container(
              width: 2,
              height: 12,
              color: tokens.colorFor(threshold.tone),
            ),
          ),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                target.label ?? 'Progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.mutedForeground,
                ),
              ),
            ),
            Text(
              '${target.currentLabel} / ${target.targetLabel}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 10,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: target.progress,
                    backgroundColor: scheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
                  ),
                ),
              ),
              ...markerWidgets,
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCaption extends StatelessWidget {
  const _StatusCaption({
    required this.tone,
    required this.tokens,
    required this.label,
  });

  final DashboardMetricTone tone;
  final DashboardMetricsTheme tokens;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = tokens.colorFor(tone);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label ?? '',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.source, required this.tokens});

  final DashboardMetricSource source;
  final DashboardMetricsTheme tokens;

  @override
  Widget build(BuildContext context) {
    final freshnessColor = switch (source.freshness) {
      DashboardMetricFreshness.fresh => tokens.success,
      DashboardMetricFreshness.stale => tokens.warning,
      DashboardMetricFreshness.unknown => tokens.mutedForeground,
    };
    final freshnessIcon = switch (source.freshness) {
      DashboardMetricFreshness.fresh => Icons.check_circle_outline_rounded,
      DashboardMetricFreshness.stale => Icons.schedule_rounded,
      DashboardMetricFreshness.unknown => Icons.info_outline_rounded,
    };

    return Row(
      children: [
        Icon(freshnessIcon, size: 14, color: freshnessColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            source.updatedAtLabel == null
                ? '${source.label} · ${source.freshnessLabel ?? ''}'
                : '${source.label} · ${source.updatedAtLabel} · ${source.freshnessLabel ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: freshnessColor,
            ),
          ),
        ),
        if (source.detail != null)
          Tooltip(
            message: source.detail!,
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: tokens.mutedForeground,
            ),
          ),
      ],
    );
  }
}

