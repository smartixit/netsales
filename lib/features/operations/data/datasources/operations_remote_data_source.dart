import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/operations/data/models/sale_invoice_model.dart';
import 'package:netsales/features/operations/data/models/voucher_request_model.dart';

/// ============================================================================
/// عقد مصدر البيانات البعيد للعمليات (OperationsRemoteDataSource Contract)
/// ============================================================================
abstract class OperationsRemoteDataSource {
  Future<ApiResponse<List<SaleInvoiceModel>>> getSaleInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  });

  Future<ApiResponse<SaleInvoiceModel>> getSaleInvoiceDetails(int id);

  Future<ApiResponse<List<VoucherRequestModel>>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  });

  Future<ApiResponse<VoucherRequestModel>> getVoucherRequestDetails(int id);

  Future<ApiResponse<VoucherRequestModel>> approveVoucherRequest(
    int id, {
    String? notes,
  });

  Future<ApiResponse<VoucherRequestModel>> rejectVoucherRequest(
    int id, {
    required String reason,
  });

  Future<ApiResponse<VoucherRequestModel>> cancelVoucherRequest(int id);

  Future<ApiResponse<VoucherRequestModel>> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  });

  Future<ApiResponse<SaleInvoiceModel>> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  });

  Future<ApiResponse<VoucherRequestModel>> updateVoucherRequest(
    int id, {
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? requestNote,
  });

  Future<ApiResponse<void>> deleteVoucherRequest(int id);
}
