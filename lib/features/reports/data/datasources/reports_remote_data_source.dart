import 'package:netsales/core/models/api_response.dart';

abstract interface class ReportsRemoteDataSource {
  Future<ApiResponse<Map<String, dynamic>>> fetchReport({
    required Map<String, dynamic> query,
  });

  Future<ApiResponse<Map<String, dynamic>>> requestExport({
    required Map<String, dynamic> payload,
  });

  Future<ApiResponse<Map<String, dynamic>>> getExportStatus(String exportId);

  Future<List<int>?> downloadExport(String downloadUrl);
}
