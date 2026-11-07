import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
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
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (saleType?.isNotEmpty ?? false) 'sale_type': saleType,
      if (search?.trim().isNotEmpty ?? false) 'search': search!.trim(),
      if (fromDate?.isNotEmpty ?? false) 'from_date': fromDate,
      if (toDate?.isNotEmpty ?? false) 'to_date': toDate,
      'cursor': ?cursor,
      'per_page': ?perPage,
    };

    final response = await remoteDataSource.getInvoices(query: query);

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
    return response.data!;
  }
}
