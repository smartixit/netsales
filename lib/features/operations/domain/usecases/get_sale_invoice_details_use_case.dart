import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class GetSaleInvoiceDetailsUseCase {
  final OperationsRepository _repository;

  const GetSaleInvoiceDetailsUseCase(this._repository);

  Future<SaleInvoiceEntity> call(int id) {
    return _repository.getSaleInvoiceDetails(id);
  }
}
