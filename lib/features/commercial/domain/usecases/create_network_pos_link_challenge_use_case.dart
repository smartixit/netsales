import 'package:netsales/features/commercial/domain/entities/network_pos_link_challenge_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام إنشاء تحدي ربط مشفر عبر رمز QR
class CreateNetworkPosLinkChallengeUseCase {
  const CreateNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkChallengeEntity> execute({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  }) {
    return _repository.createLinkChallenge(
      networkId: networkId,
      posId: posId,
      posUuid: posUuid,
      durationMinutes: durationMinutes,
    );
  }

  Future<NetworkPosLinkChallengeEntity> call({
    required int networkId,
    int? posId,
    String? posUuid,
    int? durationMinutes,
  }) => execute(
    networkId: networkId,
    posId: posId,
    posUuid: posUuid,
    durationMinutes: durationMinutes,
  );
}
