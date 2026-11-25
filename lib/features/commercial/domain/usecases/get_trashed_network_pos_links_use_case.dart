import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';

class GetTrashedNetworkPosLinksUseCase {
  const GetTrashedNetworkPosLinksUseCase(this._repository);

  final CommercialRepository _repository;

  PaginatedList<NetworkPosLinkEntity> call({required int entityId, required bool isNetwork, String? cursor, int perPage = 15}) {
    return _repository.getTrashedNetworkPosLinks({required int entityId, required bool isNetwork, String? cursor, int perPage = 15});
  }
}
