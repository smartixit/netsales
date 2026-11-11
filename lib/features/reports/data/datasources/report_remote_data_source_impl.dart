import 'package:dio/dio.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/reports/data/datasources/report_remote_data_source.dart';
import 'package:netsales/features/reports/domain/entities/report_catalog_item.dart';
import 'package:netsales/features/reports/domain/entities/report_run.dart';

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  const ReportRemoteDataSourceImpl();

  String _base(int networkId) => '/networks/$networkId/reports';

  @override
  Future<ApiResponse<List<ReportCatalogItem>>> getNetworkCatalog(int networkId) =>
      ApiService.instance.get<List<ReportCatalogItem>>(
        '${_base(networkId)}/catalog',
        fromJson: (data) => data is List
            ? data.whereType<Map>().map((row) =>
                ReportCatalogItem.fromJson(Map<String, dynamic>.from(row)))
                .toList(growable: false)
            : const <ReportCatalogItem>[],
      );

  @override
  Future<ApiResponse<ReportRun>> createNetworkRun({
    required int networkId,
    required String reportKey,
    required Map<String, dynamic> filters,
  }) => ApiService.instance.post<ReportRun>(
    '${_base(networkId)}/runs',
    data: {'report_key': reportKey, 'filters': filters},
    fromJson: (data) => ReportRun.fromJson(Map<String, dynamic>.from(data as Map)),
  );

  @override
  Future<ApiResponse<ReportRun>> getNetworkRun({
    required int networkId,
    required int reportRunId,
  }) => ApiService.instance.get<ReportRun>(
    '${_base(networkId)}/runs/$reportRunId',
    fromJson: (data) => ReportRun.fromJson(Map<String, dynamic>.from(data as Map)),
  );

  @override
  Future<List<int>> downloadArtifact(String url) async {
    final response = await ApiService.instance.dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('ملف التقرير المسترجع فارغ.');
    }
    return bytes;
  }
}
