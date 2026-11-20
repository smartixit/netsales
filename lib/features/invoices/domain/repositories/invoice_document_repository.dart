import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// واجهة تصدير وطباعة المستندات والمحررات الرسمية للفواتير
abstract interface class InvoiceDocumentRepository {
  /// طباعة الفاتورة مباشرة عبر الطابعة المتصلة
  Future<bool> printInvoice(InvoiceEntity invoice);

  /// مشاركة ملف PDF الخاص بالفاتورة عبر تطبيقات التواصل
  Future<bool> shareInvoice(InvoiceEntity invoice);

  /// تصدير وحفظ ملف PDF للفاتورة في ذاكرة الجهاز
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice);
}
