import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام جلب فواتير المشتريات لنقطة البيع
class GetPosInvoicesUseCase {
  final InvoiceRepository repository;

  const GetPosInvoicesUseCase(this.repository);

  Future<PaginatedList<InvoiceEntity>> call({
    int? posId,
    int? networkId,
    String? saleType,
    String? paymentStatus,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) {
    return repository.getInvoices(
      posId: posId,
      networkId: networkId,
      saleType: saleType,
      paymentStatus: paymentStatus,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
