import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';

abstract interface class ReportRepository {
  Future<List<ReportCatalogItem>> getNetworkCatalog(int networkId);
  Future<ReportRun> createNetworkRun({
    required int networkId,
    required String reportKey,
    required Map<String, dynamic> filters,
  });
  Future<ReportRun> getNetworkRun({
    required int networkId,
    required int reportRunId,
  });
  Future<void> downloadArtifact({
    required String url,
    required String fileName,
  });
  Future<void> shareArtifact({
    required String url,
    required String fileName,
  });
}
