import 'package:netsales/features/reports/domain/entities/report_export_job.dart';
import 'package:netsales/features/reports/domain/entities/report_type.dart';
import 'package:netsales/features/reports/domain/repositories/reports_repository.dart';

class RequestReportExportUseCase {
  const RequestReportExportUseCase(this.repository);
  final ReportsRepository repository;

  Future<ReportExportJob> call({
    required ReportType type,
    required int networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  }) => repository.requestExport(
    type: type,
    networkId: networkId,
    posId: posId,
    fromDate: fromDate,
    toDate: toDate,
  );
}
