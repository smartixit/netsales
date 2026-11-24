import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';

class GetPackagePosDiscountsUseCase {
  const GetPackagePosDiscountsUseCase(this.repository);
  final PackagePosDiscountRepository repository;
  Future<PaginatedList<PackagePosDiscountEntity>> call({
    required int networkId, required int packageId, String? search, String? cursor, String? status, String? validityState,
  }) => repository.getForPackage(
    networkId: networkId, packageId: packageId, search: search, cursor: cursor,
    status: status, validityState: validityState,
  );
}
