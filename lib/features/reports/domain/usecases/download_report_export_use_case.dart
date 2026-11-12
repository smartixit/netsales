import 'package:netsales/features/reports/domain/repositories/reports_repository.dart';

class DownloadReportExportUseCase {
  const DownloadReportExportUseCase(this.repository);
  final ReportsRepository repository;
  Future<List<int>> call(String url) => repository.downloadExport(url);
}
