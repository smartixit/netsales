import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// تطبيق مستودع فواتير المبيعات المعتمد
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
  }) {
    return remoteDataSource.getInvoices(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      paymentStatus: paymentStatus,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      perPage: perPage,
    );
  }

  @override
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId) {
    return remoteDataSource.getInvoiceDetails(invoiceId);
  }

  @override
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) {
    return remoteDataSource.createDirectInvoice(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      idempotencyKey: idempotencyKey,
    );
  }
}
