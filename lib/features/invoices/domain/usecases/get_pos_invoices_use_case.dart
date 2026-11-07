import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام جلب فواتير نقطة البيع (فواتير المشتريات)
class GetPosInvoicesUseCase {
  final InvoiceRepository repository;

  const GetPosInvoicesUseCase(this.repository);

  Future<PaginatedList<InvoiceEntity>> call({
    int? posId,
    String? saleType,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  }) {
    return repository.getInvoices(
      posId: posId,
      saleType: saleType,
      search: search,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      perPage: perPage,
    );
  }
}

