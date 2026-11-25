import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class DeleteNetworkUseCase {
  const DeleteNetworkUseCase(this._repository);
  final CommercialRepository _repository;

  Future<void> call(int networkId) => _repository.deleteNetwork(networkId);
}
