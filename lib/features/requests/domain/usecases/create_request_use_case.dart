import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام تقديم طلب توريد كروت جديد
class CreateRequestUseCase {
  final RequestRepository _repository;

  const CreateRequestUseCase(this._repository);

  Future<RequestEntity> call(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) {
    return _repository.createRequest(
      data,
      idempotencyKey: idempotencyKey,
    );
  }
}
