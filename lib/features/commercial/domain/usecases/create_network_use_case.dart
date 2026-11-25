import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class CreateNetworkUseCase {
  const CreateNetworkUseCase(this._repository);
  final CommercialRepository _repository;

  Future<NetworkEntity> call(Map<String, dynamic> payload) =>
      _repository.createNetwork(payload);
}
