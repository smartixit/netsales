import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_status_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// استرجاع الحالة الحالية لدعوة الربط من المصدر المعتمد.
class GetNetworkPosLinkChallengeStatusUseCase {
  const GetNetworkPosLinkChallengeStatusUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkChallengeStatusEntity> call(String challengeUuid) {
    return _repository.getNetworkPosLinkChallengeStatus(challengeUuid);
  }
}
