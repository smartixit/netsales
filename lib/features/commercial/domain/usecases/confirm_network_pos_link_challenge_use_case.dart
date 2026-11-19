import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class ConfirmNetworkPosLinkChallengeUseCase {
  const ConfirmNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> call({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) {
    return _repository.confirmNetworkPosLinkChallenge(
      challengeUuid: challengeUuid,
      posId: posId,
      posUuid: posUuid,
    );
  }
}
