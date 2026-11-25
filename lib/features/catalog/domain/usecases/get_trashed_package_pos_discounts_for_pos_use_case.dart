import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';

class GetTrashedPackagePosDiscountsForPosUseCase {
  const GetTrashedPackagePosDiscountsForPosUseCase(this._repository);
  final PackagePosDiscountRepository _repository;

  Future<PaginatedList<PackagePosDiscountEntity>> call({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  }) => _repository.getTrashedForPos(
    networkId: networkId,
    posId: posId,
    cursor: cursor,
    perPage: perPage,
  );
}
