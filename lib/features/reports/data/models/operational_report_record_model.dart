import 'package:netsales/features/reports/domain/entities/operational_report_record.dart';

class OperationalReportRecordModel extends OperationalReportRecord {
  const OperationalReportRecordModel(super.values);

  factory OperationalReportRecordModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('تنسيق سجل التقرير غير صالح.');
    }
    return OperationalReportRecordModel(Map<String, dynamic>.from(json));
  }
}
