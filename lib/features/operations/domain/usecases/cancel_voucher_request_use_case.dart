import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class CancelVoucherRequestUseCase {
  final OperationsRepository _repository;

  const CancelVoucherRequestUseCase(this._repository);

  Future<VoucherRequestEntity> call(int id) {
    return _repository.cancelVoucherRequest(id);
  }
}
