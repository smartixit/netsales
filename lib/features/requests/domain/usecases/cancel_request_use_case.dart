import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام إلغاء طلب الكروت قيد الانتظار
class CancelRequestUseCase {
  final RequestRepository _repository;

  const CancelRequestUseCase(this._repository);

  Future<RequestEntity> call(int requestId) {
    return _repository.cancelRequest(requestId);
  }
}

