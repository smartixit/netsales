import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';

abstract class PackagePosDiscountRepository {
  Future<PaginatedList<PackagePosDiscountEntity>> getForPackage({
    required int networkId, required int packageId, String? search, String? cursor,
  });
}
