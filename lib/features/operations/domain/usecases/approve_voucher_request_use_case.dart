import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام اعتماد طلب توريد الكروت (ApproveVoucherRequestUseCase)
/// ============================================================================
class ApproveVoucherRequestUseCase {
  final OperationsRepository _repository;

  const ApproveVoucherRequestUseCase(this._repository);

  Future<VoucherRequestEntity> call(
    int id, {
    String? notes,
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? idempotencyKey,
  }) {
    return _repository.approveVoucherRequest(
      id,
      notes: notes,
      saleType: saleType,
      items: items,
      idempotencyKey: idempotencyKey,
    );
  }
}
