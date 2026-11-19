import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// العقد التجريدي لمستودع فواتير المبيعات والمشتريات الرسمية
abstract class InvoiceRepository {
  /// جلب قائمة الفواتير المالية مع الفلترة والترقيم بالمؤشر
  Future<PaginatedList<InvoiceEntity>> getInvoices({
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

  /// جلب تفاصيل فاتورة مالية محددة بالمعرف الرقمي
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId);

  /// إنشاء فاتورة مبيعات مباشرة مع الحساب المالي السيادي على الخادم
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  });
}
