import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class UpdateNetworkPosAgreementDraftUseCase {
  const UpdateNetworkPosAgreementDraftUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosAgreementEntity> call({
    required int networkPosId,
    required int agreementId,
    required Map<String, dynamic> payload,
  }) {
    return _repository.updateNetworkPosAgreementDraft(
      networkPosId: networkPosId,
      agreementId: agreementId,
      payload: payload,
    );
  }
}
