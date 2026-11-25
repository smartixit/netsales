import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';

class CreateNetworkPosAgreementDraftUseCase {
  const CreateNetworkPosAgreementDraftUseCase(this._repository);

  final CommercialRepository _repository;

  Future<NetworkPosAgreementEntity> call({required int networkPosId, required Map<String, dynamic> payload}) {
    return _repository.createNetworkPosAgreementDraft({required int networkPosId, required Map<String, dynamic> payload});
  }
}
