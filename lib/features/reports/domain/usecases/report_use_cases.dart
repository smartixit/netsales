import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';
import 'package:netsales/features/reports/domain/repositories/report_repository.dart';

class GetNetworkReportCatalogUseCase {
  const GetNetworkReportCatalogUseCase(this.repository);
  final ReportRepository repository;
  Future<List<ReportCatalogItem>> call(int networkId) =>
      repository.getNetworkCatalog(networkId);
}

class CreateNetworkReportRunUseCase {
  const CreateNetworkReportRunUseCase(this.repository);
  final ReportRepository repository;
  Future<ReportRun> call({
    required int networkId,
    required String reportKey,
    Map<String, dynamic> filters = const {},
  }) => repository.createNetworkRun(
    networkId: networkId,
    reportKey: reportKey,
    filters: filters,
  );
}

class GetNetworkReportRunUseCase {
  const GetNetworkReportRunUseCase(this.repository);
  final ReportRepository repository;
  Future<ReportRun> call({
    required int networkId,
    required int reportRunId,
  }) => repository.getNetworkRun(
    networkId: networkId,
    reportRunId: reportRunId,
  );
}

class DownloadReportArtifactUseCase {
  const DownloadReportArtifactUseCase(this.repository);
  final ReportRepository repository;
  Future<void> call({required String url, required String fileName}) =>
      repository.downloadArtifact(url: url, fileName: fileName);
}
