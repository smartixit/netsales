import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/operations/data/models/request_pricing_preview_model.dart';
import 'package:netsales/features/operations/data/models/sale_invoice_model.dart';
import 'package:netsales/features/operations/data/models/sales_trend_point_model.dart';
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

  Future<ApiResponse<List<SalesTrendPointModel>>> getSalesTrend({
    String period = 'daily',
    int? networkId,
    int? posId,
    String? fromDate,
    String? toDate,
  });

  Future<ApiResponse<List<VoucherRequestModel>>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  });

  Future<ApiResponse<VoucherRequestModel>> getVoucherRequestDetails(int id);

  Future<ApiResponse<RequestPricingPreviewModel>> previewRequestModification(
    int id, {
    required List<Map<String, dynamic>> items,
    String? saleType,
    String? requestNote,
  });

  Future<ApiResponse<Map<String, dynamic>>> approveVoucherRequest(
    int id, {
    String? notes,
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? idempotencyKey,
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
    String? idempotencyKey,
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
    String? idempotencyKey,
  });

  Future<ApiResponse<void>> deleteVoucherRequest(int id);
}
