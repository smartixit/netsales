import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام استرجاع تفاصيل فاتورة محددة
class GetInvoiceDetailsUseCase {
  final InvoiceRepository _repository;

  const GetInvoiceDetailsUseCase(this._repository);

  Future<InvoiceEntity> call(int invoiceId) {
    if (invoiceId <= 0) {
      throw ArgumentError.value(
        invoiceId,
        'invoiceId',
        'معرف الفاتورة غير صالح',
      );
    }
    return _repository.getInvoiceDetails(invoiceId);
  }
}
