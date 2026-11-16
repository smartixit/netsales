import 'package:netsales/features/invoices/data/models/invoice_model.dart';
import 'package:netsales/features/requests/data/models/request_model.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';

/// DTO للاستجابة المركبة من API اعتماد الطلب.
class RequestApprovalResultModel extends RequestApprovalResultEntity {
  const RequestApprovalResultModel({
    required super.request,
    required super.invoice,
  });

  factory RequestApprovalResultModel.fromJson(Map<String, dynamic> json) {
    final requestJson = json['request'];
    final invoiceJson = json['invoice'];
    if (requestJson is! Map || invoiceJson is! Map) {
      throw const FormatException(
        'استجابة اعتماد الطلب لا تحتوي على الطلب والفاتورة معاً.',
      );
    }
    return RequestApprovalResultModel(
      request: RequestModel.fromJson(Map<String, dynamic>.from(requestJson)),
      invoice: InvoiceModel.fromJson(Map<String, dynamic>.from(invoiceJson)),
    );
  }
}
