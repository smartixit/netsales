import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام رفض طلب الكروت مع توثيق السبب
class RejectRequestUseCase {
  final RequestRepository _repository;

  const RejectRequestUseCase(this._repository);

  Future<RequestEntity> call(
    int requestId,
    String rejectionReason,
  ) {
    return _repository.rejectRequest(
      requestId,
      rejectionReason,
    );
  }
}

