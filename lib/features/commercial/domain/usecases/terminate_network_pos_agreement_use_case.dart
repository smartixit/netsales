import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';

class TerminateNetworkPosAgreementUseCase {
  const TerminateNetworkPosAgreementUseCase(this._repository);

  final CommercialRepository _repository;

  NetworkPosAgreementEntity call({required int networkPosId, required int agreementId}) {
    return _repository.terminateNetworkPosAgreement({required int networkPosId, required int agreementId});
  }
}
