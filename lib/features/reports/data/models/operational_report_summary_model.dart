import 'package:document_engine/document_engine.dart';
import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';

class OperationalReportSummaryModel extends OperationalReportSummary {
  const OperationalReportSummaryModel(
    super.values, {
    super.metricDefinitions,
    super.metricLabels,
    super.chartSlots,
    super.reportTitle,
  });

  factory OperationalReportSummaryModel.fromJson(
    dynamic json, {
    required List<ReportMetricSlotDefinition> metricDefinitions,
    required Map<String, String> metricLabels,
    required List<OperationalReportChartSlot> chartSlots,
    required String reportTitle,
  }) {
    if (json is! Map) {
      throw const FormatException('تنسيق ملخص التقرير غير صالح.');
    }
    return OperationalReportSummaryModel(
      Map<String, dynamic>.from(json),
      metricDefinitions: metricDefinitions,
      metricLabels: metricLabels,
      chartSlots: chartSlots,
      reportTitle: reportTitle,
    );
  }
}
