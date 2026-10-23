import 'package:netsales/features/operations/domain/entities/voucher_request_entity.dart';
import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class GetVoucherRequestDetailsUseCase {
  final OperationsRepository _repository;

  const GetVoucherRequestDetailsUseCase(this._repository);

  Future<VoucherRequestEntity> call(int id) {
    return _repository.getVoucherRequestDetails(id);
  }
}
