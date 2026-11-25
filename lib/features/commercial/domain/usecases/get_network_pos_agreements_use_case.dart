import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_agreement_entity.dart';

class GetNetworkPosAgreementsUseCase {
  const GetNetworkPosAgreementsUseCase(this._repository);

  final CommercialRepository _repository;

  PaginatedList<NetworkPosAgreementEntity> call({required int networkPosId, String? cursor, int perPage = 15}) {
    return _repository.getNetworkPosAgreements({required int networkPosId, String? cursor, int perPage = 15});
  }
}
