import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';

class OperationalReportMetric {
  const OperationalReportMetric({
    required this.id,
    required this.label,
    required this.value,
    this.isCurrency = false,
  });

  final String id;
  final String label;
  final String value;
  final bool isCurrency;
}

class OperationalReportSummary {
  const OperationalReportSummary(
    this.values, {
    this.metricDefinitions = const <ReportMetricSlotDefinition>[],
    this.metricLabels = const <String, String>{},
    this.chartSlots = const <OperationalReportChartSlot>[],
    this.reportTitle = '',
  });

  final Map<String, dynamic> values;
  final List<ReportMetricSlotDefinition> metricDefinitions;
  final Map<String, String> metricLabels;
  final List<OperationalReportChartSlot> chartSlots;
  final String reportTitle;

  Map<String, List<Map<String, dynamic>>> get charts {
    final raw = values['charts'];
    if (raw is! Map) return const {};
    final result = <String, List<Map<String, dynamic>>>{};
    for (final slot in chartSlots) {
      final points = raw[slot.id];
      if (points is List) {
        result[slot.id] = points
            .whereType<Map>()
            .map((point) => Map<String, dynamic>.from(point))
            .toList(growable: false);
      }
    }
    return result;
  }

  List<OperationalReportMetric> get metrics => metricDefinitions
      .map((definition) {
        final rawValue = values[definition.id];
        if (rawValue == null) return null;
        return OperationalReportMetric(
          id: definition.id,
          label: metricLabels[definition.id] ?? definition.labelKey,
          value: rawValue.toString(),
          isCurrency: definition.dataType == ReportDataType.decimal,
        );
      })
      .whereType<OperationalReportMetric>()
      .toList(growable: false);
}
