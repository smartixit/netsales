import 'package:netsales/features/reports/domain/entities/operational_report_summary.dart';

class OperationalReportSummaryModel extends OperationalReportSummary {
  const OperationalReportSummaryModel(super.values);

  factory OperationalReportSummaryModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('تنسيق ملخص التقرير غير صالح.');
    }
    return OperationalReportSummaryModel(Map<String, dynamic>.from(json));
  }
}
