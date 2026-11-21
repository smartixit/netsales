import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/domain/entities/procurement_quote_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_preview_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';

/// واجهة مستودع دورة حياة طلبات الكروت والتوريد
abstract interface class RequestRepository {
  /// جلب ملخص إحصائي معتمد لعدد الطلبات حسب حالتها
  Future<RequestStatusSummaryEntity> getRequestStatusSummary({
    int? networkId,
    int? posId,
  });

  /// احتساب ومعاينة عرض أسعار سيادي معتمد لطلب توريد جديد
  Future<ProcurementQuoteEntity> getQuote(Map<String, dynamic> payload);

  /// جلب قائمة طلبات الكروت مع ترقيم الصفحات القائم على المؤشر (Cursor Pagination)
  Future<PaginatedList<RequestEntity>> getRequests({
    int? networkId,
    int? posId,
    String? status,
    String? search,
    String? cursor,
    int? perPage,
  });

  /// جلب تفاصيل طلب محدد بالكامل متضمناً البنود وسجل المراجعة
  Future<RequestEntity> getRequestDetails(int requestId);

  /// تقديم طلب توريد كروت جديد من نقطة البيع
  Future<RequestEntity> createRequest(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  });

  /// تعديل طلب الكروت قيد الانتظار (تغيير البنود أو الكميات أو نوع الشراء)
  Future<RequestEntity> updateRequest(int requestId, Map<String, dynamic> data);

  /// إلغاء طلب الكروت قيد الانتظار من قبل نقطة البيع
  Future<RequestEntity> cancelRequest(int requestId);

  /// حذف طلب كروت من السجل (للطلبات الملغية أو قيد الانتظار)
  Future<bool> deleteRequest(int requestId);

  /// معاينة بنود التعديل وحساب أسعارها وخصوماتها سيادياً دون تغيير الطلب.
  Future<RequestModificationPreviewEntity> previewRequestModification(
    int requestId,
    List<RequestModificationLineEntity> items,
  );

  /// اعتماد الطلب مع البنود نفسها ورموز المعاينة الصادرة من الخادم.
  Future<RequestApprovalResultEntity> approveRequest(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
    double? paidAmount,
  });

  /// رفض طلب الكروت مع توثيق السبب المعتمد من قبل مزود الشبكة
  Future<RequestEntity> rejectRequest(int requestId, String rejectionReason);
}
