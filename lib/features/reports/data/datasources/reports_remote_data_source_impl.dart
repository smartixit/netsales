import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/reports/data/datasources/reports_remote_data_source.dart';

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  const ReportsRemoteDataSourceImpl();

  @override
  Future<ApiResponse<Map<String, dynamic>>> fetchReport({
    required Map<String, dynamic> query,
  }) => ApiService.instance.get<Map<String, dynamic>>(
    ApiConstants.operationalReports,
    queryParameters: query,
    fromJson: (data) => Map<String, dynamic>.from(data as Map),
  );

  @override
  Future<ApiResponse<Map<String, dynamic>>> requestExport({
    required Map<String, dynamic> payload,
  }) => ApiService.instance.post<Map<String, dynamic>>(
    ApiConstants.operationalReportExports,
    data: payload,
    fromJson: (data) => Map<String, dynamic>.from(data as Map),
  );

  @override
  Future<ApiResponse<Map<String, dynamic>>> getExportStatus(String exportId) =>
      ApiService.instance.get<Map<String, dynamic>>(
        '${ApiConstants.operationalReportExports}/$exportId',
        fromJson: (data) => Map<String, dynamic>.from(data as Map),
      );

  @override
  Future<List<int>?> downloadExport(String downloadUrl) =>
      ApiService.instance.downloadBytes(downloadUrl);
}
