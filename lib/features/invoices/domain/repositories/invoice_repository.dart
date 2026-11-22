import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/direct_sale_invoice_item_input_entity.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

/// واجهة مستودع فواتير المبيعات والمشتريات
abstract interface class InvoiceRepository {
  /// استرجاع قائمة الفواتير مع الترقيم المستند إلى المؤشرات (Cursor Pagination)
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

  /// استرجاع تفاصيل فاتورة محددة بالكامل مع كافة البنود والجهات
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId);

  /// إنشاء فاتورة بيع مباشرة جديدة من قبل مشغل الشبكة
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectSaleInvoiceItemInputEntity> items,
    required String idempotencyKey,
    double? paidAmount,
  });
}
