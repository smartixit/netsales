import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام إلغاء وإبطال تحدي الربط المشفر
class RevokeNetworkPosLinkChallengeUseCase {
  const RevokeNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<void> execute(String uuid) {
    return _repository.revokeLinkChallenge(uuid);
  }

  Future<void> call(String uuid) => execute(uuid);
}
