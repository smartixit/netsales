import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetTrashedNetworksUseCase {
  const GetTrashedNetworksUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkEntity>> call({
    String? search,
    String? cursor,
    int perPage = 15,
  }) => _repository.getTrashedNetworks(
    search: search,
    cursor: cursor,
    perPage: perPage,
  );
}
