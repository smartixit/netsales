import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';

class ActivateNetworkPosAgreementUseCase {
  const ActivateNetworkPosAgreementUseCase(this._repository);

  final CommercialRepository _repository;

  NetworkPosAgreementEntity call({required int networkPosId, required int agreementId}) {
    return _repository.activateNetworkPosAgreement({required int networkPosId, required int agreementId});
  }
}
