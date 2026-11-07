import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام جلب فواتير الشبكة (فواتير مبيعات الجملة)
class GetNetworkInvoicesUseCase {
  final InvoiceRepository repository;

  const GetNetworkInvoicesUseCase(this.repository);

  Future<PaginatedList<InvoiceEntity>> call({
    int? networkId,
    String? saleType,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) {
    return repository.getInvoices(
      networkId: networkId,
      saleType: saleType,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

