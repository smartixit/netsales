import 'package:flutter/material.dart';

import '../enums/chart_state.dart';
import '../models/chart_period_option.dart';
import '../models/chart_series.dart';
import '../theme/charts_theme.dart';
import 'chart_data_table.dart';
import 'chart_state_view.dart';

/// Reusable chart surface with header, configurable periods, actions and states.
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.description,
    this.state = ChartState.data,
    this.stateMessage,
    this.stateDetails,
    this.onRetry,
    this.height = 300,
    this.series = const <ChartSeries>[],
    this.showDataTable = false,
    this.periods = const <ChartPeriodOption>[],
    this.selectedPeriodId,
    this.onPeriodChanged,
    this.actions = const <Widget>[],
    this.footer,
    this.badge,
  });

  final String title;
  final String? description;
  final Widget chart;
  final ChartState state;
  final String? stateMessage;
  final String? stateDetails;
  final VoidCallback? onRetry;
  final double height;
  final List<ChartSeries> series;
  final bool showDataTable;
  final List<ChartPeriodOption> periods;
  final String? selectedPeriodId;
  final ValueChanged<String>? onPeriodChanged;
  final List<Widget> actions;
  final Widget? footer;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardSurface,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: theme.border),
        boxShadow: theme.cardElevation,
      ),
      padding: EdgeInsets.all(theme.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartCardHeader(
            title: title,
            description: description,
            badge: badge,
            actions: actions,
          ),
          if (periods.isNotEmpty) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: periods.map((period) {
                  final selected = period.id == selectedPeriodId;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(period.label),
                      selected: selected,
                      onSelected: onPeriodChanged == null
                          ? null
                          : (_) => onPeriodChanged!(period.id),
                      selectedColor: scheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: selected
                            ? scheme.onPrimaryContainer
                            : theme.mutedText,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(color: theme.border),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            width: double.infinity,
            child: state == ChartState.data
                ? (showDataTable
                    ? ChartDataTable(series: series)
                    : chart)
                : ChartStateView(
                    state: state,
                    message: stateMessage,
                    details: stateDetails,
                    onRetry: onRetry,
                  ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _ChartCardHeader extends StatelessWidget {
  const _ChartCardHeader({
    required this.title,
    required this.actions,
    this.description,
    this.badge,
  });

  final String title;
  final String? description;
  final Widget? badge;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.text,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (badge != null) badge!,
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: theme.mutedText,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: actions,
          ),
      ],
    );
  }
}

/// Theme-aware accessible action for chart-card toolbars.
class ChartToolbarAction extends StatelessWidget {
  const ChartToolbarAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = ChartsTheme.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: theme.mutedText),
                  if (label != null) ...[
                    const SizedBox(width: 6),
                    Text(label!, style: TextStyle(color: theme.text)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
