import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetMyPosUseCase {
  const GetMyPosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<List<PosEntity>> call() => _repository.getMyPos();
}
