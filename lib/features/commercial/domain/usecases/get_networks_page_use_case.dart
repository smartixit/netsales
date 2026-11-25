import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetNetworksPageUseCase {
  const GetNetworksPageUseCase(this._repository);
  final CommercialRepository _repository;

  Future<PaginatedList<NetworkEntity>> call({
    String? search,
    String? status,
    int? governorateId,
    String? cursor,
    int perPage = 15,
  }) => _repository.getNetworksPage(
    search: search,
    status: status,
    governorateId: governorateId,
    cursor: cursor,
    perPage: perPage,
  );
}
