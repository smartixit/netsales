import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/network_pos_event_entity.dart';

class GetNetworkPosEventsUseCase {
  const GetNetworkPosEventsUseCase(this._repository);

  final CommercialRepository _repository;

  PaginatedList<NetworkPosEventEntity> call({required int networkPosId, String? cursor, int perPage = 20}) {
    return _repository.getNetworkPosEvents({required int networkPosId, String? cursor, int perPage = 20});
  }
}
