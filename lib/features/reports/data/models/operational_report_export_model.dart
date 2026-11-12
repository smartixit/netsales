import 'package:netsales/features/reports/domain/entities/operational_report_export.dart';

class OperationalReportExportModel extends OperationalReportExport {
  const OperationalReportExportModel({
    required super.exportId,
    required super.status,
    super.statusLabel,
    super.recordCount,
    super.artifactSize,
    super.downloadUrl,
    super.failureCode,
  });

  factory OperationalReportExportModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('تنسيق استجابة تصدير التقرير غير صالح.');
    }
    final map = Map<String, dynamic>.from(json);
    return OperationalReportExportModel(
      exportId: (map['export_id'] ?? map['export_uuid'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      statusLabel: map['status_label']?.toString(),
      recordCount: (map['record_count'] as num?)?.toInt(),
      artifactSize: (map['artifact_size'] as num?)?.toInt(),
      downloadUrl: map['download_url']?.toString(),
      failureCode: map['failure_code']?.toString(),
    );
  }
}
