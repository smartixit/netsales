import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class CreateNetworkPosAgreementDraftUseCase {
  const CreateNetworkPosAgreementDraftUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosAgreementEntity> call({
    required int networkPosId,
    required Map<String, dynamic> payload,
  }) {
    return _repository.createNetworkPosAgreementDraft(
      networkPosId: networkPosId,
      payload: payload,
    );
  }
}
