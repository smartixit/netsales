import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// Output boundary for generated invoice documents.
///
/// PDF rendering and platform I/O remain infrastructure concerns.
abstract interface class InvoiceDocumentRepository {
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice);

  Future<bool> shareInvoice(InvoiceEntity invoice);

  Future<bool> printInvoice(InvoiceEntity invoice);
}
