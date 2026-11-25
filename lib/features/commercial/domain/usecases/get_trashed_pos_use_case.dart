import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/commercial/domain/entities/pos_entity.dart';
import 'package:netsales/features/commercial/domain/repositories/commercial_repository.dart';

class GetTrashedPosUseCase {
  const GetTrashedPosUseCase(this._repository);

  final CommercialRepository _repository;

  Future<PaginatedList<PosEntity>> call({
    String? search,
    String? cursor,
    int perPage = 15,
  }) => _repository.getTrashedPos(
    search: search,
    cursor: cursor,
    perPage: perPage,
  );
}
