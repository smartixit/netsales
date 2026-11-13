import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';

class OperationalReportSummaryModel extends OperationalReportSummary {
  const OperationalReportSummaryModel(
    super.values, {
    super.metricDefinitions,
    super.reportTitle,
  });

  factory OperationalReportSummaryModel.fromJson(
    dynamic json, {
    required List<Map<String, dynamic>> metricDefinitions,
    required String reportTitle,
  }) {
    if (json is! Map) {
      throw const FormatException('تنسيق ملخص التقرير غير صالح.');
    }
    return OperationalReportSummaryModel(
      Map<String, dynamic>.from(json),
      metricDefinitions: metricDefinitions,
      reportTitle: reportTitle,
    );
  }
}
