import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetPosPageUseCase {
  const GetPosPageUseCase(this._repository);
  final CommercialRepository _repository;

  Future<PaginatedList<PosEntity>> call({
    String? search,
    String? status,
    int? governorateId,
    String? cursor,
    int perPage = 15,
  }) => _repository.getPosPage(
    search: search,
    status: status,
    governorateId: governorateId,
    cursor: cursor,
    perPage: perPage,
  );
}
