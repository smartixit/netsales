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
    this.metricDefinitions = const <Map<String, dynamic>>[],
    this.reportTitle = '',
  });

  final Map<String, dynamic> values;
  final List<Map<String, dynamic>> metricDefinitions;
  final String reportTitle;

  List<OperationalReportMetric> get metrics {
    return metricDefinitions.map((definition) {
      final id = definition['id']?.toString() ?? '';
      final label = definition['label']?.toString() ?? id;
      final dataType = definition['data_type']?.toString();
      final rawValue = values[id];
      if (rawValue == null) return null;
      return OperationalReportMetric(
        id: id,
        label: label,
        value: rawValue?.toString() ?? '—',
        isCurrency: dataType == 'decimal' || dataType == 'currency',
      );
    }).whereType<OperationalReportMetric>().where((metric) => metric.id.isNotEmpty).toList(growable: false);
  }
}
