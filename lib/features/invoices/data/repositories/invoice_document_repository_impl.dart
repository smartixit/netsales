import 'package:netsales/features/invoices/data/services/invoice_document_service.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// Infrastructure adapter between the invoice use case and document engine.
class InvoiceDocumentRepositoryImpl implements InvoiceDocumentRepository {
  const InvoiceDocumentRepositoryImpl({required this.documentService});

  final InvoiceDocumentService documentService;

  @override
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) async {
    final result = await documentService.exportAndSaveInvoice(invoice);
    return result.isSuccess;
  }

  @override
  Future<bool> shareInvoice(InvoiceEntity invoice) {
    return documentService.shareInvoice(invoice);
  }

  @override
  Future<bool> printInvoice(InvoiceEntity invoice) {
    return documentService.printInvoice(invoice);
  }
}
