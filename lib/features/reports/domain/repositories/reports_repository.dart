import 'package:netsales/features/reports/domain/entities/report_export_job.dart';
import 'package:netsales/features/reports/domain/entities/report_page.dart';
import 'package:netsales/features/reports/domain/entities/report_type.dart';

abstract interface class ReportsRepository {
  Future<ReportPage> fetch({
    required ReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
    String? cursor,
    int perPage = 25,
  });

  Future<ReportExportJob> requestExport({
    required ReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  });

  Future<ReportExportJob> getExportStatus(String exportId);

  Future<List<int>> downloadExport(String url);
}
