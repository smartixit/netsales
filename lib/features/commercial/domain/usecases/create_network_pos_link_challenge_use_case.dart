import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام توليد دعوة وتحدي ربط تجاري عبر رمز QR
class CreateNetworkPosLinkChallengeUseCase {
  const CreateNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkChallengeEntity> call({
    required int networkId,
    required String posUuid,
    int durationMinutes = 15,
  }) {
    return _repository.createNetworkPosLinkChallenge(
      networkId: networkId,
      posUuid: posUuid,
      durationMinutes: durationMinutes,
    );
  }
}
