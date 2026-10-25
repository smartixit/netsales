import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

/// ============================================================================
/// حالة استخدام إنشاء طلب توريد كروت جديد (CreateVoucherRequestUseCase)
/// ============================================================================
class CreateVoucherRequestUseCase {
  final OperationsRepository _repository;

  const CreateVoucherRequestUseCase(this._repository);

  Future<VoucherRequestEntity> call({
    required int networkId,
    required int posId,
    required String saleType,
    required List<Map<String, dynamic>> items,
    String? requestNote,
  }) {
    return _repository.createVoucherRequest(
      networkId: networkId,
      posId: posId,
      saleType: saleType,
      items: items,
      requestNote: requestNote,
    );
  }
}
