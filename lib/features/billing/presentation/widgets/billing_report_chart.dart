import 'package:flutter/material.dart';
import 'package:netsales/widgets/charts/charting.dart';

/// محول عقد بيانات مخططات تقارير Billing إلى إطار المخططات المشترك.
class BillingReportChart extends StatelessWidget {
  const BillingReportChart({
    super.key,
    required this.payload,
  });

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final rawData = payload['data'];
    final data = rawData is List
        ? rawData.whereType<Map<String, dynamic>>().map((row) => Map<String, dynamic>.from(row)).toList()
        : <Map<String, dynamic>>[];
    final rawSeries = payload['series'];
    final seriesConfig = rawSeries is List
        ? rawSeries.whereType<Map<String, dynamic>>().map((item) => Map<String, dynamic>.from(item)).toList()
        : <Map<String, dynamic>>[];
    final typeName = (payload['type'] ?? 'column').toString();
    final type = ChartType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => ChartType.column,
    );
    final family = switch (type) {
      ChartType.pie || ChartType.doughnut || ChartType.radialBar => ChartFamily.circular,
      ChartType.funnel || ChartType.pyramid => ChartFamily.funnel,
      ChartType.sparkLine || ChartType.sparkArea || ChartType.sparkBar ||
      ChartType.sparkWinLoss => ChartFamily.spark,
      ChartType.scatter || ChartType.bubble || ChartType.histogram ||
      ChartType.boxAndWhisker || ChartType.errorBar || ChartType.rangeColumn =>
        ChartFamily.statistical,
      ChartType.candle || ChartType.hilo || ChartType.ohlc => ChartFamily.financial,
      ChartType.line || ChartType.spline || ChartType.fastLine ||
      ChartType.area || ChartType.splineArea || ChartType.stepLine ||
      ChartType.stepArea || ChartType.rangeArea || ChartType.splineRangeArea =>
        ChartFamily.cartesian,
      _ => ChartFamily.comparison,
    };
    final definitions = seriesConfig.isEmpty
        ? <Map<String, dynamic>>[
            <String, dynamic>{
              'key': 'value',
              'label': payload['value_label'] ?? 'القيمة',
            },
          ]
        : seriesConfig;
    final series = definitions.map((config) {
      final key = (config['key'] ?? 'value').toString();
      return ChartSeries(
        id: key,
        name: (config['label'] ?? key).toString(),
        type: type,
        data: data.map((row) => ChartDataPoint(
          x: row['label'] ?? row['x'] ?? '—',
          y: (row[key] ?? (key == 'value' ? row['value'] : null)) is num
              ? (row[key] ?? (key == 'value' ? row['value'] : null)) as num
              : num.tryParse((row[key] ?? (key == 'value' ? row['value'] : null))?.toString() ?? ''),
          label: row['label']?.toString(),
        )).toList(growable: false),
      );
    }).toList(growable: false);

    final hasValues = series.any((item) => item.data.any((point) => point.y != null));
    return ChartCard(
      title: payload['title']?.toString() ?? 'مخطط التقرير',
      description: payload['description']?.toString(),
      height: 320,
      state: hasValues ? ChartState.data : ChartState.empty,
      chart: ChartRenderer(
        definition: ChartDefinition(
          family: family,
          type: type,
          series: series,
          options: const ChartOptions(
            showLegend: true,
            showTooltip: true,
            showDataLabels: false,
            animate: true,
          ),
        ),
      ),
    );
  }
}
