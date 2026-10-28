import 'package:netsales/features/operations/domain/repositories/operations_repository.dart';

class DeleteVoucherRequestUseCase {
  final OperationsRepository _repository;

  const DeleteVoucherRequestUseCase(this._repository);

  Future<void> call(int id) {
    return _repository.deleteVoucherRequest(id);
  }
}
