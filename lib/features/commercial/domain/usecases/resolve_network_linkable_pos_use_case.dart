import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// Resolve one exact POS business code for a network invitation.
class ResolveNetworkLinkablePosUseCase {
  const ResolveNetworkLinkablePosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkLinkablePosEntity> call({
    required int networkId,
    required String posBusinessCode,
  }) {
    return _repository.resolveNetworkLinkablePos(
      networkId: networkId,
      posBusinessCode: posBusinessCode,
    );
  }
}
