import 'package:netsales/features/operations/domain/entities/sale_invoice_entity.dart';
import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';

/// ============================================================================
/// عقد مستودع العمليات والمبيعات (OperationsRepository Contract)
/// ============================================================================
/// يحدد عقود العمليات التشغيلية دون الارتباط بأي مصدر بيانات ملموس.
abstract class OperationsRepository {
  /// جلب قائمة فواتير مبيعات الكروت مع الفلترة والبحث
  Future<List<SaleInvoiceEntity>> getSaleInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    int perPage = 20,
    int page = 1,
  });

  /// جلب تفاصيل فاتورة بيع محددة مع بنود الباقات
  Future<SaleInvoiceEntity> getSaleInvoiceDetails(int id);

  /// جلب قائمة طلبات توريد الكروت مع الفلترة والبحث
  Future<List<VoucherRequestEntity>> getVoucherRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    int perPage = 20,
    int page = 1,
  });

  /// جلب تفاصيل طلب توريد محدد
  Future<VoucherRequestEntity> getVoucherRequestDetails(int id);

  /// اعتماد طلب توريد كروت من قبل مزود الشبكة
  Future<VoucherRequestEntity> approveVoucherRequest(
    int id, {
    String? notes,
  });

  /// رفض طلب توريد كروت مع ذكر السبب
  Future<VoucherRequestEntity> rejectVoucherRequest(
    int id, {
    required String reason,
  });

  /// إلغاء طلب توريد كروت من قبل نقطة البيع
  Future<VoucherRequestEntity> cancelVoucherRequest(int id);

  /// إنشاء طلب توريد كروت جديد
  Future<VoucherRequestEntity> createVoucherRequest({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  });

  /// إنشاء وتوليد فاتورة مبيعات مباشرة
  Future<SaleInvoiceEntity> createSaleInvoice({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    double? paidAmount,
  });
}
