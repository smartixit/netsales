import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source.dart';
import 'package:netsales/features/requests/data/models/procurement_quote_model.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';
import 'package:netsales/features/requests/data/models/request_approval_result_model.dart';
import 'package:netsales/features/requests/data/models/request_status_summary_model.dart';

/// تطبيق مصدر البيانات البعيد لطلبات الكروت عبر ApiService
class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  const RequestRemoteDataSourceImpl();

  @override
  Future<ApiResponse<ProcurementQuoteModel>> getQuote(
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<ProcurementQuoteModel>(
      ApiConstants.voucherRequestsQuote,
      data: data,
      fromJson: (resData) =>
          ProcurementQuoteModel.fromJson(resData as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<RequestModel>>> getRequests({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<RequestModel>>(
      ApiConstants.voucherRequests,
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => RequestModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<RequestStatusSummaryModel>> getRequestStatusSummary({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<RequestStatusSummaryModel>(
      ApiConstants.voucherRequestsSummary,
      queryParameters: query,
      fromJson: (data) =>
          RequestStatusSummaryModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestModel>> getRequestDetails(int requestId) {
    return ApiService.instance.get<RequestModel>(
      ApiConstants.voucherRequest(requestId),
      fromJson: (data) => RequestModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestModel>> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) {
    return ApiService.instance.post<RequestModel>(
      ApiConstants.voucherRequests,
      data: data,
      idempotencyKey: idempotencyKey,
      fromJson: (data) => RequestModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestModel>> updateRequest(
    int requestId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.put<RequestModel>(
      ApiConstants.voucherRequest(requestId),
      data: data,
      fromJson: (data) => RequestModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestModel>> cancelRequest(int requestId) {
    return ApiService.instance.post<RequestModel>(
      ApiConstants.voucherRequestCancel(requestId),
      fromJson: (data) => RequestModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<dynamic>> deleteRequest(int requestId) {
    return ApiService.instance.delete<dynamic>(
      ApiConstants.voucherRequest(requestId),
    );
  }

  @override
  Future<ApiResponse<RequestApprovalResultModel>> approveRequest(
    int requestId, {
    Map<String, dynamic>? data,
  }) {
    return ApiService.instance.post<RequestApprovalResultModel>(
      ApiConstants.voucherRequestApprove(requestId),
      data: data,
      fromJson: (responseData) => RequestApprovalResultModel.fromJson(
        responseData as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> previewRequestModification(
    int requestId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<Map<String, dynamic>>(
      ApiConstants.voucherRequestPreviewModification(requestId),
      data: data,
      fromJson: (responseData) {
        if (responseData is Map<String, dynamic>) {
          return responseData;
        }
        throw const FormatException(
          'Invalid request modification preview response.',
        );
      },
    );
  }

  @override
  Future<ApiResponse<RequestModel>> rejectRequest(
    int requestId,
    Map<String, dynamic> data,
  ) {
    return ApiService.instance.post<RequestModel>(
      ApiConstants.voucherRequestReject(requestId),
      data: data,
      fromJson: (resData) =>
          RequestModel.fromJson(resData as Map<String, dynamic>),
    );
  }
}
