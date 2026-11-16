import 'package:netsales/features/invoices/domain/entities/invoice_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// نتيجة الاعتماد الرسمية؛ تحفظ الطلب بعد اعتماده والفاتورة المنشأة معه.
class RequestApprovalResultEntity {
  final RequestEntity request;
  final InvoiceEntity invoice;

  const RequestApprovalResultEntity({
    required this.request,
    required this.invoice,
  });
}
