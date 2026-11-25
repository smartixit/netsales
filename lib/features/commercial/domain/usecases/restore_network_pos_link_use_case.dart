import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class RestoreNetworkPosLinkUseCase {
  const RestoreNetworkPosLinkUseCase(this._repository);

  final CommercialRepository _repository;

  void call(int networkPosId) {
    return _repository.restoreNetworkPosLink(int networkPosId);
  }
}
