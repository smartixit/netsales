import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/enums/sale_type.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/invoices/domain/entities/direct_invoice_item_input_entity.dart';

/// تطبيق مصدر بيانات الفواتير عبر خدمة الـ ApiService المركزية
class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  const InvoiceRemoteDataSourceImpl();

  @override
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
  }) async {
    final queryParams = <String, dynamic>{
      'network_id': ?networkId,
      'pos_id': ?posId,
      if (saleType != null && saleType.isNotEmpty) 'sale_type': saleType,
      if (paymentStatus != null && paymentStatus.isNotEmpty)
        'payment_status': paymentStatus,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (fromDate != null && fromDate.isNotEmpty) 'from_date': fromDate,
      if (toDate != null && toDate.isNotEmpty) 'to_date': toDate,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      'per_page': perPage ?? 15,
    };

    final response = await ApiService.instance.get<List<InvoiceModel>>(
      ApiConstants.saleInvoices,
      queryParameters: queryParams,
      fromJson: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(InvoiceModel.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
    );

    return PaginatedList<InvoiceModel>(
      items: response.data ?? const [],
      nextCursor: response.meta?['next_cursor'] as String?,
      prevCursor: response.meta?['prev_cursor'] as String?,
      perPage: response.meta?['per_page'] as int? ?? perPage ?? 15,
    );
  }

  @override
  Future<InvoiceModel> getInvoiceDetails(int invoiceId) async {
    final response = await ApiService.instance.get<InvoiceModel>(
      ApiConstants.saleInvoice(invoiceId),
      fromJson: (data) => InvoiceModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('لم يتم استرجاع بيانات الفاتورة المحددة من الخادم.');
    }
    return result;
  }

  @override
  Future<InvoiceModel> createDirectInvoice({
    required int networkId,
    required int posId,
    required SaleType saleType,
    required List<DirectInvoiceItemInputEntity> items,
    required String idempotencyKey,
  }) async {
    final payload = <String, dynamic>{
      'network_id': networkId,
      'pos_id': posId,
      'sale_type': saleType.wireValue,
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };

    final response = await ApiService.instance.post<InvoiceModel>(
      ApiConstants.saleInvoices,
      data: payload,
      idempotencyKey: idempotencyKey,
      fromJson: (data) => InvoiceModel.fromJson(data as Map<String, dynamic>),
    );

    final result = response.data;
    if (result == null) {
      throw Exception('فشل إنشاء الفاتورة المباشرة على الخادم.');
    }
    return result;
  }
}
