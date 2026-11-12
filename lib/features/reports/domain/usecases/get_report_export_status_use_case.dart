import 'package:netsales/features/reports/domain/entities/report_export_job.dart';
import 'package:netsales/features/reports/domain/repositories/reports_repository.dart';

class GetReportExportStatusUseCase {
  const GetReportExportStatusUseCase(this.repository);
  final ReportsRepository repository;
  Future<ReportExportJob> call(String exportId) =>
      repository.getExportStatus(exportId);
}
