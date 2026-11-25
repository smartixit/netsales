import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';

abstract class PackagePosDiscountRepository {
  Future<PaginatedList<PackagePosDiscountEntity>> getForPos({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  });

  Future<PackagePosDiscountEntity> create(Map<String, dynamic> payload);
  Future<PackagePosDiscountEntity> update(int discountId, Map<String, dynamic> payload);
  Future<PackagePosDiscountEntity> toggleStatus(int discountId);
  Future<void> delete(int discountId);

  Future<PaginatedList<PackagePosDiscountEntity>> getForPackage({
    required int networkId, required int packageId, String? search, String? cursor, String? status, String? validityState,
  });
}
