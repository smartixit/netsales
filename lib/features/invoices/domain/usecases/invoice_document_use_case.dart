import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/invoices/domain/repositories/invoice_document_repository.dart';

/// حالة استخدام العمليات المستندية على الفاتورة (طباعة، مشاركة، تصدير PDF)
class InvoiceDocumentUseCase {
  final InvoiceDocumentRepository _repository;

  const InvoiceDocumentUseCase(this._repository);

  /// طباعة الفاتورة
  Future<bool> printInvoice(InvoiceEntity invoice) {
    return _repository.printInvoice(invoice);
  }

  /// مشاركة الفاتورة
  Future<bool> shareInvoice(InvoiceEntity invoice) {
    return _repository.shareInvoice(invoice);
  }

  /// تصدير وحفظ الفاتورة
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice) {
    return _repository.exportAndSaveInvoice(invoice);
  }
}
