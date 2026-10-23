import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام رفض طلب توريد الكروت (RejectVoucherRequestUseCase)
/// ============================================================================
class RejectVoucherRequestUseCase {
  final OperationsRepository _repository;

  const RejectVoucherRequestUseCase(this._repository);

  Future<VoucherRequestEntity> call(int id, {required String reason}) {
    return _repository.rejectVoucherRequest(id, reason: reason);
  }
}
