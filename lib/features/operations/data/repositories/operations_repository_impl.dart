import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/features/operations/data/datasources/operations_remote_data_source.dart';
import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// تطبيق مستودع العمليات والمبيعات (OperationsRepositoryImpl)
/// ============================================================================
/// يطبق عقد الدومين، يستدعي مصدر البيانات البعيد، ويعيد الكيانات مباشرة.
class OperationsRepositoryImpl implements OperationsRepository {
  final OperationsRemoteDataSource _remoteDataSource;

  const OperationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<SaleInvoiceEntity>> getSaleInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async {
    final response = await _remoteDataSource.getSaleInvoices(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      search: search,
      perPage: perPage,
      page: page,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر استرجاع فواتير المبيعات',
    );
  }

  @override
  Future<SaleInvoiceEntity> getSaleInvoiceDetails(int id) async {
    final response = await _remoteDataSource.getSaleInvoiceDetails(id);

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر استرجاع تفاصيل الفاتورة',
    );
  }

  @override
  Future<List<VoucherRequestEntity>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async {
    final response = await _remoteDataSource.getVoucherRequests(
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
      perPage: perPage,
      page: page,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر استرجاع طلبات توريد الكروت',
    );
  }

  @override
  Future<VoucherRequestEntity> getVoucherRequestDetails(int id) async {
    final response = await _remoteDataSource.getVoucherRequestDetails(id);

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر استرجاع تفاصيل طلب الكروت',
    );
  }

  @override
  Future<VoucherRequestEntity> approveVoucherRequest(
    int id, {
    String? notes,
  }) async {
    final response = await _remoteDataSource.approveVoucherRequest(
      id,
      notes: notes,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر اعتماد طلب الكروت',
    );
  }

  @override
  Future<VoucherRequestEntity> rejectVoucherRequest(
    int id, {
    required String reason,
  }) async {
    final response = await _remoteDataSource.rejectVoucherRequest(
      id,
      reason: reason,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر رفض طلب الكروت',
    );
  }

  @override
  Future<VoucherRequestEntity> cancelVoucherRequest(int id) async {
    final response = await _remoteDataSource.cancelVoucherRequest(id);

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر إلغاء طلب الكروت',
    );
  }

  @override
  Future<VoucherRequestEntity> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  }) async {
    final response = await _remoteDataSource.createVoucherRequest(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      requestNote: requestNote,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر إنشاء طلب توريد الكروت',
    );
  }

  @override
  Future<SaleInvoiceEntity> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  }) async {
    final response = await _remoteDataSource.createSaleInvoice(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      paidAmount: paidAmount,
    );

    if (response.data != null) {
      return response.data!;
    }

    throw AppException(
      response.message.isNotEmpty
          ? response.message
          : 'تعذر إنشاء فاتورة المبيعات',
    );
  }
}
