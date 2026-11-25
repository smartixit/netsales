import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class UpdatePosUseCase {
  const UpdatePosUseCase(this._repository);
  final CommercialRepository _repository;

  Future<PosEntity> call({
    required int posId,
    required Map<String, dynamic> payload,
  }) => _repository.updatePos(posId, payload);
}
