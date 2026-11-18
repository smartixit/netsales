import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام جلب ملخص حالات طلبات التوريد المعتمد من الخادم
class GetRequestStatusSummaryUseCase {
  final RequestRepository _repository;

  const GetRequestStatusSummaryUseCase(this._repository);

  Future<RequestStatusSummaryEntity> call({int? networkId, int? posId}) {
    return _repository.getRequestStatusSummary(
      networkId: networkId,
      posId: posId,
    );
  }
}
