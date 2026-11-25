import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class CreatePosUseCase {
  const CreatePosUseCase(this._repository);
  final CommercialRepository _repository;

  Future<PosEntity> call(Map<String, dynamic> payload) =>
      _repository.createPos(payload);
}
