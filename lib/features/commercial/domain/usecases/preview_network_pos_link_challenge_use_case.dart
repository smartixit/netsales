import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام فحص ومعاينة دعوة الربط المشفرة
class PreviewNetworkPosLinkChallengeUseCase {
  const PreviewNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkPreviewEntity> call({
    required String payload,
    required String posUuid,
  }) {
    return _repository.previewNetworkPosLinkChallenge(
      payload: payload,
      posUuid: posUuid,
    );
  }
}
