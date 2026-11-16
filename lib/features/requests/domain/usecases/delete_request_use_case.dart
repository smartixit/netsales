import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام حذف طلب توريد من السجل (Delete Request Use Case)
class DeleteRequestUseCase {
  final RequestRepository _repository;

  const DeleteRequestUseCase(this._repository);

  Future<bool> call(int requestId) {
    return _repository.deleteRequest(requestId);
  }
}
