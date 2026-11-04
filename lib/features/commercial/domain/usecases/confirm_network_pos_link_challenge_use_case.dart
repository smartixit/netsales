import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام تأكيد واعتماد ربط نقطة البيع بالشبكة عبر التحدي المشفر
class ConfirmNetworkPosLinkChallengeUseCase {
  const ConfirmNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkEntity> execute({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) {
    return _repository.confirmLinkChallenge(
      challengeUuid: challengeUuid,
      posId: posId,
      posUuid: posUuid,
    );
  }

  Future<NetworkPosLinkEntity> call({
    required String challengeUuid,
    int? posId,
    String? posUuid,
  }) => execute(challengeUuid: challengeUuid, posId: posId, posUuid: posUuid);
}
