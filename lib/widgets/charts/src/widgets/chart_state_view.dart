import 'package:flutter/material.dart';

import 'package:netsales/widgets/buttons/custom_button.dart';

import '../enums/chart_state.dart';
import '../theme/charts_theme.dart';

class ChartStateView extends StatelessWidget {
  const ChartStateView({
    super.key,
    required this.state,
    this.message,
    this.details,
    this.onRetry,
  });

  final ChartState state;
  final String? message;
  final String? details;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (state == ChartState.loading) {
      return _ChartSkeleton(theme: theme);
    }

    final (icon, color, defaultMessage) = switch (state) {
      ChartState.empty => (
        Icons.query_stats_rounded,
        theme.mutedText,
        'لا توجد بيانات كافية لعرض المخطط',
      ),
      ChartState.error => (
        Icons.error_outline_rounded,
        scheme.error,
        'تعذر تحميل بيانات المخطط',
      ),
      ChartState.offline => (
        Icons.cloud_off_rounded,
        theme.mutedText,
        'لا يوجد اتصال حالياً',
      ),
      ChartState.stale => (
        Icons.history_rounded,
        scheme.tertiary,
        'تعرض بيانات قديمة حتى يتم التحديث',
      ),
      ChartState.loading => (
        Icons.hourglass_empty_rounded,
        theme.mutedText,
        'جارٍ التحميل',
      ),
      ChartState.data => (
        Icons.query_stats_rounded,
        theme.mutedText,
        'لا توجد بيانات للعرض',
      ),
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(theme.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(
              message ?? defaultMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: theme.text,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 5),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: theme.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              CustomButton.secondary(
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton({required this.theme});

  final ChartsTheme theme;

  @override
  Widget build(BuildContext context) {
    final base = theme.border.withValues(alpha: 0.55);
    return Padding(
      padding: EdgeInsets.all(theme.cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List<Widget>.generate(7, (index) {
                final factor = <double>[
                  0.35,
                  0.58,
                  0.46,
                  0.82,
                  0.62,
                  0.94,
                  0.7,
                ][index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FractionallySizedBox(
                      heightFactor: factor,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: base,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            width: 140,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ],
      ),
    );
  }
}
