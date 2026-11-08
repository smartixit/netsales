import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input.dart';

/// واجهة مستودع فواتير المبيعات والمشتريات
abstract interface class InvoiceRepository {
  /// استرجاع قائمة الفواتير مع الترقيم بالمؤشر والفلاتر المعتمدة
  Future<PaginatedList<InvoiceEntity>> getInvoices({
    int? networkId,
    int? posId,
    String? saleType,
    String? search,
    String? fromDate,
    String? toDate,
    String? cursor,
    int? perPage,
  });

  /// إنشاء فاتورة مبيعات مباشرة. لا تستقبل أسعاراً أو خصومات أو إجماليات من العميل.
  Future<InvoiceEntity> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInput> items,
  });

  /// استرجاع تفاصيل فاتورة محددة بكافة بنودها وأطرافها
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId);
}

