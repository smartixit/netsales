import 'package:netsales/features/invoices/data/services/invoice_document_service.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// تطبيق مستودع عمليات المستندات للفاتورة
class InvoiceDocumentRepositoryImpl implements InvoiceDocumentRepository {
  final InvoiceDocumentService documentService;

  const InvoiceDocumentRepositoryImpl({required this.documentService});

  @override
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) {
    return documentService.exportAndSaveInvoice(invoice);
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
