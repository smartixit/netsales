import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_repository.dart';

/// حالة استخدام جلب تفاصيل فاتورة محددة
class GetInvoiceDetailsUseCase {
  final InvoiceRepository repository;

  const GetInvoiceDetailsUseCase(this.repository);

  Future<InvoiceEntity> call(int invoiceId) {
    return repository.getInvoiceDetails(invoiceId);
  }
}

