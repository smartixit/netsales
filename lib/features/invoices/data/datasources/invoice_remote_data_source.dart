import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

/// واجهة مصدر البيانات البعيد لفواتير المبيعات
abstract interface class InvoiceRemoteDataSource {
  /// استرجاع قائمة الفواتير
  Future<ApiResponse<List<InvoiceModel>>> getInvoices({
    Map<String, dynamic>? query,
  });

  /// إنشاء فاتورة مبيعات مباشرة ببيانات كمية فقط.
  Future<ApiResponse<InvoiceModel>> createDirectInvoice(
    Map<String, dynamic> payload, {
    required String idempotencyKey,
  });

  /// استرجاع تفاصيل فاتورة محددة
  Future<ApiResponse<InvoiceModel>> getInvoiceDetails(int invoiceId);
}

