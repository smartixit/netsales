import 'package:netsales/features/invoices/data/services/invoice_document_service.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// تطبيق مستودع طباعة وتصدير مستندات الفواتير
class InvoiceDocumentRepositoryImpl implements InvoiceDocumentRepository {
  final InvoiceDocumentService _documentService;

  const InvoiceDocumentRepositoryImpl({
    this._documentService = const InvoiceDocumentService(),
  });

  @override
  Future<bool> printInvoice(InvoiceEntity invoice) {
    return _documentService.printInvoice(invoice);
  }

  @override
  Future<bool> shareInvoice(InvoiceEntity invoice) {
    return _documentService.shareInvoice(invoice);
  }

  @override
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) {
    return _documentService.exportAndSaveInvoice(invoice);
  }
}
