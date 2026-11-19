import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// حالة استخدام العمليات المستندية للفواتير (تصدير، طباعة، مشاركة)
class InvoiceDocumentUseCase {
  final InvoiceDocumentRepository repository;

  const InvoiceDocumentUseCase(this.repository);

  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) {
    return repository.exportAndSaveInvoice(invoice);
  }

  Future<bool> shareInvoice(InvoiceEntity invoice) {
    return repository.shareInvoice(invoice);
  }

  Future<bool> printInvoice(InvoiceEntity invoice) {
    return repository.printInvoice(invoice);
  }
}
