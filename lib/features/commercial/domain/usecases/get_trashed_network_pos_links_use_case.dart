import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetTrashedNetworkPosLinksUseCase {
  const GetTrashedNetworkPosLinksUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosLinkEntity>> call({
    required int entityId,
    required bool isNetwork,
    String? cursor,
    int perPage = 15,
  }) {
    return _repository.getTrashedNetworkPosLinks(
      entityId: entityId,
      isNetwork: isNetwork,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
