import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

/// واجهة مصدر البيانات البعيد لفواتير المبيعات
abstract interface class InvoiceRemoteDataSource {
  /// جلب قائمة الفواتير مع التصفية والترقيم
  Future<ApiResponse<List<InvoiceModel>>> getInvoices({
    Map<String, dynamic>? query,
  });

  /// جلب تفاصيل فاتورة محددة
  Future<ApiResponse<InvoiceModel>> getInvoiceDetails(int invoiceId);

  /// إنشاء فاتورة بيع مباشرة جديدة
  Future<ApiResponse<InvoiceModel>> createDirectInvoice(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  });
}
