import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام تعديل طلب توريد كروت قيد الانتظار (Update Pending Request Use Case)
class UpdateRequestUseCase {
  final RequestRepository _repository;

  const UpdateRequestUseCase(this._repository);

  Future<RequestEntity> call(int requestId, Map<String, dynamic> data) {
    return _repository.updateRequest(requestId, data);
  }
}
