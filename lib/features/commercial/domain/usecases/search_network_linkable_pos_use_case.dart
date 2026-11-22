import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_linkable_pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class SearchNetworkLinkablePosUseCase {
  const SearchNetworkLinkablePosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkLinkablePosEntity>> call({
    required int networkId,
    required String search,
    String? cursor,
    int perPage = 15,
  }) {
    return _repository.searchNetworkLinkablePos(
      networkId: networkId,
      search: search,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
