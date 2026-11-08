import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';

/// واجهة مصدر البيانات البعيد لطلبات الكروت والتوريد
abstract interface class RequestRemoteDataSource {
  Future<ApiResponse<List<RequestModel>>> getRequests({
    Map<String, dynamic>? query,
  });

  Future<ApiResponse<RequestModel>> getRequestDetails(int requestId);

  Future<ApiResponse<RequestModel>> createRequest(Map<String, dynamic> data);

  Future<ApiResponse<RequestModel>> cancelRequest(int requestId);

  Future<ApiResponse<dynamic>> approveRequest(
    int requestId, {
    Map<String, dynamic>? data,
  });

  Future<ApiResponse<Map<String, dynamic>>> previewRequestModification(
    int requestId,
    Map<String, dynamic> data,
  );

  Future<ApiResponse<RequestModel>> rejectRequest(
    int requestId,
    Map<String, dynamic> data,
  );
}

