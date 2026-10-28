import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source.dart';
import 'package:netsales/features/operations/data/models/sale_invoice_model.dart';
import 'package:netsales/features/operations/data/models/sales_trend_point_model.dart';
import 'package:netsales/features/operations/data/models/voucher_request_model.dart';

/// ============================================================================
/// تطبيق مصدر البيانات البعيد للعمليات (OperationsRemoteDataSourceImpl)
/// ============================================================================
class OperationsRemoteDataSourceImpl implements OperationsRemoteDataSource {
  const OperationsRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<SaleInvoiceModel>>> getSaleInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  }) {
    final queryParameters = <String, dynamic>{
      if (networkId != null) 'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (saleType != null && saleType.isNotEmpty && saleType != 'ALL')
        'sale_type': saleType,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'per_page': perPage,
      'page': page,
    };

    return ApiService.instance.getList<SaleInvoiceModel>(
      ApiConstants.saleInvoices,
      queryParameters: queryParameters,
      fromJson: (json) => SaleInvoiceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<SaleInvoiceModel>> getSaleInvoiceDetails(int id) {
    return ApiService.instance.get<SaleInvoiceModel>(
      ApiConstants.saleInvoice(id),
      fromJson: (json) => SaleInvoiceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<SalesTrendPointModel>>> getSalesTrend({
    String period = 'daily',
    int? networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  }) {
    final queryParameters = <String, dynamic>{
      'period': period,
      if (networkId != null) 'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
    };

    return ApiService.instance.getList<SalesTrendPointModel>(
      ApiConstants.saleInvoicesTrend,
      queryParameters: queryParameters,
      fromJson: (json) =>
          SalesTrendPointModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<List<VoucherRequestModel>>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  }) {
    final queryParameters = <String, dynamic>{
      if (networkId != null) 'network_id': networkId,
      if (posId != null) 'pos_id': posId,
      if (status != null && status.isNotEmpty && status != 'ALL')
        'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      'per_page': perPage,
      'page': page,
    };

    return ApiService.instance.getList<VoucherRequestModel>(
      ApiConstants.voucherRequests,
      queryParameters: queryParameters,
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> getVoucherRequestDetails(int id) {
    return ApiService.instance.get<VoucherRequestModel>(
      ApiConstants.voucherRequest(id),
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> approveVoucherRequest(
    int id, {
    String? notes,
  }) {
    return ApiService.instance.post<VoucherRequestModel>(
      ApiConstants.voucherRequestApprove(id),
      data: {
        if (notes != null && notes.trim().isNotEmpty) 'request_note': notes.trim(),
      },
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> rejectVoucherRequest(
    int id, {
    required String reason,
  }) {
    return ApiService.instance.post<VoucherRequestModel>(
      ApiConstants.voucherRequestReject(id),
      data: {
        'request_note': reason.trim(),
      },
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> cancelVoucherRequest(int id) {
    return ApiService.instance.post<VoucherRequestModel>(
      ApiConstants.voucherRequestCancel(id),
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  }) {
    return ApiService.instance.post<VoucherRequestModel>(
      ApiConstants.voucherRequests,
      data: {
        'network_id': networkId,
        'pos_id': posId,
        'sale_type': saleType,
        'items': items,
        if (requestNote != null && requestNote.trim().isNotEmpty)
          'request_note': requestNote.trim(),
      },
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<SaleInvoiceModel>> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  }) {
    return ApiService.instance.post<SaleInvoiceModel>(
      ApiConstants.saleInvoices,
      data: {
        'network_id': networkId,
        'pos_id': posId,
        'sale_type': saleType,
        'items': items,
        if (paidAmount != null) 'paid_amount': paidAmount,
      },
      fromJson: (json) => SaleInvoiceModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<VoucherRequestModel>> updateVoucherRequest(
    int id, {
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? requestNote,
  }) {
    return ApiService.instance.put<VoucherRequestModel>(
      ApiConstants.voucherRequest(id),
      data: {
        if (saleType != null) 'sale_type': saleType,
        if (items != null) 'items': items,
        if (requestNote != null) 'request_note': requestNote.trim(),
      },
      fromJson: (json) => VoucherRequestModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<void>> deleteVoucherRequest(int id) {
    return ApiService.instance.delete<void>(
      ApiConstants.voucherRequest(id),
    );
  }
}

