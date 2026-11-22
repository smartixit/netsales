import 'package:netsales/features/requests/domain/entities/request_approval_result_entity.dart';
import 'package:netsales/features/requests/domain/entities/request_modification_line_entity.dart';
import 'package:netsales/features/requests/domain/repositories/request_repository.dart';

/// حالة استخدام اعتماد طلب الكروت وتوليد الفاتورة
class ApproveRequestUseCase {
  final RequestRepository _repository;

  const ApproveRequestUseCase(this._repository);

  Future<RequestApprovalResultEntity> call(
    int requestId, {
    String? requestNote,
    List<RequestModificationLineEntity>? items,
  }) {
    return _repository.approveRequest(
      requestId,
      requestNote: requestNote,
      items: items,
    );
  }
}
