import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/requests/data/datasources/request_remote_data_source.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';

/// تطبيق مصدر البيانات البعيد لطلبات الكروت عبر ApiService
class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  const RequestRemoteDataSourceImpl();

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
  Future<ApiResponse<RequestModel>> getRequestDetails(int requestId) {
    return ApiService.instance.get<RequestModel>(
      ApiConstants.voucherRequest(requestId),
      fromJson: (data) => RequestModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<RequestModel>> createRequest(Map<String, dynamic> data) {
    return ApiService.instance.post<RequestModel>(
      ApiConstants.voucherRequests,
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
  Future<ApiResponse<dynamic>> approveRequest(
    int requestId, {
    Map<String, dynamic>? data,
  }) {
    return ApiService.instance.post<dynamic>(
      ApiConstants.voucherRequestApprove(requestId),
      data: data,
      fromJson: (resData) {
        if (resData is Map<String, dynamic> && resData.containsKey('request')) {
          return RequestModel.fromJson(
            resData['request'] as Map<String, dynamic>,
          );
        } else if (resData is Map<String, dynamic>) {
          return RequestModel.fromJson(resData);
        }
        return resData;
      },
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
