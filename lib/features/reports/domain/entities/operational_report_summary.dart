import 'package:document_engine/document_engine.dart';

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
    this.reportTitle = '',
  });

  final Map<String, dynamic> values;
  final List<ReportMetricSlotDefinition> metricDefinitions;
  final Map<String, String> metricLabels;
  final String reportTitle;

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
