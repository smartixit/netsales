import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_link_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetNetworkPosListUseCase {
  const GetNetworkPosListUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosLinkEntity>> call({
    required int networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) {
    return _repository.getNetworkPosList(
      networkId: networkId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
