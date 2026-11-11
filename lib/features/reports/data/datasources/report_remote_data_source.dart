import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';

abstract interface class ReportRemoteDataSource {
  Future<ApiResponse<List<ReportCatalogItem>>> getNetworkCatalog(int networkId);
  Future<ApiResponse<ReportRun>> createNetworkRun({
    required int networkId,
    required String reportKey,
    required Map<String, dynamic> filters,
  });
  Future<ApiResponse<ReportRun>> getNetworkRun({
    required int networkId,
    required int reportRunId,
  });
  Future<List<int>> downloadArtifact(String url);
}
