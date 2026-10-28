import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class UpdateVoucherRequestUseCase {
  final OperationsRepository _repository;

  const UpdateVoucherRequestUseCase(this._repository);

  Future<VoucherRequestEntity> call(
    int id, {
    String? saleType,
    List<Map<String, dynamic>>? items,
    String? requestNote,
  }) {
    return _repository.updateVoucherRequest(
      id,
      saleType: saleType,
      items: items,
      requestNote: requestNote,
    );
  }
}
