import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetNetworkDetailsUseCase {
  const GetNetworkDetailsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkEntity> call(int networkId) {
    return _repository.getNetworkDetails(networkId);
  }
}
