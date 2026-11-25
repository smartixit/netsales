import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class DeletePosUseCase {
  const DeletePosUseCase(this._repository);
  final CommercialRepository _repository;

  Future<void> call(int posId) => _repository.deletePos(posId);
}
