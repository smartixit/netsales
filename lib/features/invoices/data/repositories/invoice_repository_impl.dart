import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/domain/entities/direct_sale_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// تطبيق مستودع فواتير المبيعات والمشتريات
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceRemoteDataSource remoteDataSource;

  const InvoiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaginatedList<InvoiceEntity>> getInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? paymentStatus,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (saleType != null && saleType.isNotEmpty) 'sale_type': saleType,
      if (paymentStatus != null && paymentStatus.isNotEmpty)
        'payment_status': paymentStatus,
      if (search != null && search.isNotEmpty) 'search': search,
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': ?perPage,
    };

    final response = await remoteDataSource.getInvoices(
      query: query.isNotEmpty ? query : null,
    );

    final items = response.data ?? [];

    return PaginatedList<InvoiceEntity>(
      items: items,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
    );
  }

  @override
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId) async {
    final response = await remoteDataSource.getInvoiceDetails(invoiceId);
    if (response.data == null) {
      throw AppException('تعذر استرجاع بيانات الفاتورة رقم #$invoiceId');
    }
    return response.data!;
  }

  @override
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectSaleInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      if (saleType != SaleType.unknown) 'sale_type': saleType.wireValue,
      'items': items.map((e) => e.toJson()).toList(),
    };

    final response = await remoteDataSource.createDirectInvoice(
      payload,
      idempotencyKey: idempotencyKey,
    );

    if (response.data == null) {
      throw AppException(
        response.message.isNotEmpty
            ? response.message
            : 'رفض الخادم إنشاء الفاتورة.',
      );
    }

    return response.data!;
  }
}
