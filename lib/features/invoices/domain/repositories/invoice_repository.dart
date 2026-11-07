import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';

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

  /// استرجاع تفاصيل فاتورة محددة بكافة بنودها وأطرافها
  Future<InvoiceEntity> getInvoiceDetails(int invoiceId);
}

