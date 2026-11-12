import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// Coordinates the supported output operations for an official invoice.
class InvoiceDocumentUseCase {
  const InvoiceDocumentUseCase(this.repository);

  final InvoiceDocumentRepository repository;

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
