import 'package:netsales/features/requests/domain/entities/request_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام اعتماد طلب الكروت وتوليد الفاتورة
class ApproveRequestUseCase {
  final RequestRepository _repository;

  const ApproveRequestUseCase(this._repository);

  Future<RequestEntity> call(
    int requestId, {
    String? requestNote,
  }) {
    return _repository.approveRequest(
      requestId,
      requestNote: requestNote,
    );
  }
}

