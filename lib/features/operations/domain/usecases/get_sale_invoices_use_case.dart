import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام جلب فواتير مبيعات الكروت (GetSaleInvoicesUseCase)
/// ============================================================================
class GetSaleInvoicesUseCase {
  final OperationsRepository _repository;

  const GetSaleInvoicesUseCase(this._repository);

  Future<List<SaleInvoiceEntity>> call({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  }) {
    return _repository.getSaleInvoices(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      search: search,
      perPage: perPage,
      page: page,
    );
  }
}
