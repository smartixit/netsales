import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class RestoreNetworkUseCase {
  const RestoreNetworkUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> call(int networkId) => _repository.restoreNetwork(networkId);
}
