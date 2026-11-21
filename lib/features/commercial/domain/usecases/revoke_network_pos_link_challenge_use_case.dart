import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام إلغاء وإبطال دعوة الربط المشفرة
class RevokeNetworkPosLinkChallengeUseCase {
  const RevokeNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> call(String challengeUuid) {
    return _repository.revokeNetworkPosLinkChallenge(challengeUuid);
  }
}
