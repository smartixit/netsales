import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/requests/domain/entities/request_entity.dart';

/// واجهة مستودع دورة حياة طلبات الكروت والتوريد
abstract interface class RequestRepository {
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
  Future<RequestEntity> createRequest(Map<String, dynamic> data);

  /// إلغاء طلب الكروت قيد الانتظار من قبل نقطة البيع
  Future<RequestEntity> cancelRequest(int requestId);

  /// اعتماد طلب الكروت وتوليد الفاتورة المالية من قبل مزود الشبكة
  Future<RequestEntity> approveRequest(
    int requestId, {
    String? requestNote,
  });

  /// رفض طلب الكروت مع توثيق السبب المعتمد من قبل مزود الشبكة
  Future<RequestEntity> rejectRequest(
    int requestId,
    String rejectionReason,
  );
}

