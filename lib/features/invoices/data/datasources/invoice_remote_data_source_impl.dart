import 'package:netsales/core/constants/api_constants.dart';
import 'package:netsales/core/models/api_response.dart';
import 'package:netsales/core/services/api_service.dart';
import 'package:netsales/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:netsales/features/invoices/data/models/invoice_model.dart';

/// تطبيق مصدر البيانات البعيد لفواتير المبيعات عبر ApiService
class InvoiceRemoteDataSourceImpl implements InvoiceRemoteDataSource {
  const InvoiceRemoteDataSourceImpl();

  @override
  Future<ApiResponse<List<InvoiceModel>>> getInvoices({
    Map<String, dynamic>? query,
  }) {
    return ApiService.instance.get<List<InvoiceModel>>(
      ApiConstants.saleInvoices,
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data
              .map(
                (item) => InvoiceModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return [];
      },
    );
  }

  @override
  Future<ApiResponse<InvoiceModel>> createDirectInvoice(
    Map<String, dynamic> payload,
  ) {
    return ApiService.instance.post<InvoiceModel>(
      ApiConstants.saleInvoices,
      data: payload,
      fromJson: (data) => InvoiceModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResponse<InvoiceModel>> getInvoiceDetails(int invoiceId) {
    return ApiService.instance.get<InvoiceModel>(
      ApiConstants.saleInvoice(invoiceId),
      fromJson: (data) => InvoiceModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
