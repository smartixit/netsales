import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام جلب تفاصيل طلب الكروت مع البنود
class GetRequestDetailsUseCase {
  final RequestRepository _repository;

  const GetRequestDetailsUseCase(this._repository);

  Future<RequestEntity> call(int requestId) {
    return _repository.getRequestDetails(requestId);
  }
}

