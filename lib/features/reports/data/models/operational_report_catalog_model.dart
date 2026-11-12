import 'package:netsales/features/reports/domain/entities/operational_report_catalog.dart';

class OperationalReportCatalogModel extends OperationalReportCatalog {
  const OperationalReportCatalogModel({
    required super.schemaVersion,
    required super.reports,
  });

  factory OperationalReportCatalogModel.fromJson(dynamic json) {
    if (json is! Map) {
      throw const FormatException('تنسيق كتالوج التقارير غير صالح.');
    }
    final raw = json['reports'];
    if (raw is! List) {
      throw const FormatException('قائمة تعريفات التقارير غير صالحة.');
    }
    final reports = raw.map((item) {
      if (item is! Map) {
        throw const FormatException('تعريف تقرير غير صالح.');
      }
      return Map<String, dynamic>.from(item);
    }).toList(growable: false);
    return OperationalReportCatalogModel(
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
      reports: reports,
    );
  }
}
