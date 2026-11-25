import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class UpdateNetworkUseCase {
  const UpdateNetworkUseCase(this._repository);
  final CommercialRepository _repository;

  Future<NetworkEntity> call({
    required int networkId,
    required Map<String, dynamic> payload,
  }) => _repository.updateNetwork(networkId, payload);
}
