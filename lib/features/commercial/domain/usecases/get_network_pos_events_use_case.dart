import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetNetworkPosEventsUseCase {
  const GetNetworkPosEventsUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<NetworkPosEventEntity>> call({
    required int networkPosId,
    String? cursor,
    int perPage = 20,
  }) {
    return _repository.getNetworkPosEvents(
      networkPosId: networkPosId,
      cursor: cursor,
      perPage: perPage,
    );
  }
}
