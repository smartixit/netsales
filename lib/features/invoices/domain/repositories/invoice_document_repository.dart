import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// العقد التجريدي لعمليات المستندات والطباعة والتصدير للفاتورة
abstract class InvoiceDocumentRepository {
  /// تصدير وحفظ مستند الفاتورة كـ PDF في ذاكرة الجهاز
  Future<bool> exportAndSaveInvoice(InvoiceEntity invoice);

  /// مشاركة ملف الفاتورة عبر نافذة النظام
  Future<bool> shareInvoice(InvoiceEntity invoice);

  /// إرسال مستند الفاتورة إلى خدمة الطباعة
  Future<bool> printInvoice(InvoiceEntity invoice);
}
