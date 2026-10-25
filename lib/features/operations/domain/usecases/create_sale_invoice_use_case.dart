import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء وتوليد فاتورة مبيعات مباشرة (CreateSaleInvoiceUseCase)
/// ============================================================================
class CreateSaleInvoiceUseCase {
  final OperationsRepository _repository;

  const CreateSaleInvoiceUseCase(this._repository);

  Future<SaleInvoiceEntity> call({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  }) {
    return _repository.createSaleInvoice(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      paidAmount: paidAmount,
    );
  }
}
