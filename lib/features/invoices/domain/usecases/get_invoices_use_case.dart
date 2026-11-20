import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام جلب قائمة الفواتير العامة مع الترقيم والبحث
class GetInvoicesUseCase {
  final InvoiceRepository _repository;

  const GetInvoicesUseCase(this._repository);

  Future<PaginatedList<InvoiceEntity>> call({
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
    return _repository.getInvoices(
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
}
