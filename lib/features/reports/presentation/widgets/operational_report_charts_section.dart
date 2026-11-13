import 'package:flutter/material.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';
import 'package:netsales/widgets/charts/charting.dart';

/// Renders the chart slots and aggregates supplied by the selected server
/// provider. It never derives financial totals from the paginated client rows.
class OperationalReportChartsSection extends StatelessWidget {
  const OperationalReportChartsSection({
    required this.summary,
    super.key,
  });

  final OperationalReportSummary summary;

  @override
  Widget build(BuildContext context) {
    final chartValues = summary.charts;
    final slots = summary.chartSlots
        .where((slot) => chartValues[slot.id]?.isNotEmpty == true)
        .toList(growable: false);
    if (slots.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 338,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final rawPoints = chartValues[slot.id]!;
          final points = rawPoints.map((point) {
            final rawValue = point[slot.valueKey];
            final value = rawValue is num
                ? rawValue
                : num.tryParse(rawValue?.toString() ?? '');
            return ChartDataPoint(
              x: point[slot.labelKey]?.toString() ?? '—',
              y: value,
            );
          }).where((point) => point.y != null).toList(growable: false);

          final type = slot.chartType == 'line'
              ? ChartType.line
              : ChartType.bar;
          final series = ChartSeries(
            id: slot.id,
            name: slot.label,
            type: type,
            data: points,
          );
          final definition = ChartDefinition(
            family: ChartFamily.cartesian,
            type: type,
            series: [series],
            options: ChartOptions(
              showMarkers: type == ChartType.line,
              showTooltip: true,
              showLegend: false,
              animate: true,
            ),
          );

          return SizedBox(
            width: 440,
            child: ChartCard(
              title: slot.label,
              height: 260,
              chart: ChartRenderer(definition: definition),
              series: [series],
            ),
          );
        },
      ),
    );
  }
}
