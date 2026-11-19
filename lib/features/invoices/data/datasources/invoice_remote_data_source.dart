import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';

/// العقد التجريدي لمصدر بيانات فواتير المبيعات عبر الـ API
abstract class InvoiceRemoteDataSource {
  /// جلب قائمة الفواتير المالية مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<InvoiceModel>> getInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? paymentStatus,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  });

  /// جلب تفاصيل فاتورة مالية محددة
  Future<InvoiceModel> getInvoiceDetails(int invoiceId);

  /// إنشاء فاتورة مبيعات مباشرة مع الحساب المالي السيادي على الخادم
  Future<InvoiceModel> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  });
}
