import 'package:netsales/features/commercial/domain/entities/network_pos_link_preview_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

/// حالة استخدام معاينة وفحص تحدي ربط مشفر من جانب نقطة البيع
class PreviewNetworkPosLinkChallengeUseCase {
  const PreviewNetworkPosLinkChallengeUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosLinkPreviewEntity> execute({
    required String payload,
    int? posId,
    String? posUuid,
  }) {
    return _repository.previewLinkChallenge(
      payload: payload,
      posId: posId,
      posUuid: posUuid,
    );
  }

  Future<NetworkPosLinkPreviewEntity> call({
    required String payload,
    int? posId,
    String? posUuid,
  }) => execute(payload: payload, posId: posId, posUuid: posUuid);
}
