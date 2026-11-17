import 'package:netsales/features/requests/domain/entities/request_status_summary_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

class GetRequestStatusSummaryUseCase {
  const GetRequestStatusSummaryUseCase(this._repository);

  final RequestRepository _repository;

  Future<RequestStatusSummaryEntity> call({int? posId}) {
    return _repository.getRequestStatusSummary(posId: posId);
  }
}
