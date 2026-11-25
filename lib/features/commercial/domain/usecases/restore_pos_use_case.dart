import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class RestorePosUseCase {
  const RestorePosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> call(int posId) => _repository.restorePos(posId);
}
