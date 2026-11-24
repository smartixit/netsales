import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/datasources/package_pos_discount_remote_data_source.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';

class PackagePosDiscountRepositoryImpl implements PackagePosDiscountRepository {
  const PackagePosDiscountRepositoryImpl(this.remote);
  final PackagePosDiscountRemoteDataSource remote;
  @override
  Future<PaginatedList<PackagePosDiscountEntity>> getForPackage({
    required int networkId, required int packageId, String? search, String? cursor, String? status, String? validityState,
  }) async {
    final response=await remote.getForPackage(
      networkId: networkId, packageId: packageId, search: search, cursor: cursor,
      status: status, validityState: validityState,
    );
    if (!response.success || response.data == null) throw AppException(response.message);
    return PaginatedList<PackagePosDiscountEntity>(
      items: response.data!, nextCursor: response.nextCursor,
      prevCursor: response.prevCursor, perPage: 15,
    );
  }
}
