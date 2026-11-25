import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/datasources/package_pos_discount_remote_data_source.dart';
import 'package:netsales/features/catalog/domain/entities/package_pos_discount_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_pos_discount_repository.dart';

class PackagePosDiscountRepositoryImpl implements PackagePosDiscountRepository {
  const PackagePosDiscountRepositoryImpl(this.remote);
  final PackagePosDiscountRemoteDataSource remote;
  @override
  Future<PaginatedList<PackagePosDiscountEntity>> getForPos({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  }) async {
    final response = await remote.getForPos(
      networkId: networkId, posId: posId, cursor: cursor, perPage: perPage,
    );
    if (!response.success || response.data == null) throw AppException(response.message);
    return PaginatedList<PackagePosDiscountEntity>(
      items: response.data!,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: response.meta?['per_page'] as int? ?? perPage,
    );
  }

  @override
  Future<PaginatedList<PackagePosDiscountEntity>> getTrashedForPos({
    required int networkId,
    required int posId,
    String? cursor,
    int perPage = 15,
  }) async {
    final response = await remote.getTrashedForPos(
      networkId: networkId, posId: posId, cursor: cursor, perPage: perPage,
    );
    if (!response.success || response.data == null) throw AppException(response.message);
    return PaginatedList<PackagePosDiscountEntity>(
      items: response.data!,
      nextCursor: response.nextCursor,
      prevCursor: response.prevCursor,
      perPage: response.meta?['per_page'] as int? ?? perPage,
    );
  }

  @override
  Future<void> restore(int discountId) async {
    final response = await remote.restore(discountId);
    if (!response.success) throw AppException(response.message);
  }

  @override
  Future<PackagePosDiscountEntity> create(Map<String, dynamic> payload) async {
    final response = await remote.create(payload);
    if (!response.success || response.data == null) throw AppException(response.message);
    return response.data!;
  }

  @override
  Future<PackagePosDiscountEntity> update(int discountId, Map<String, dynamic> payload) async {
    final response = await remote.update(discountId, payload);
    if (!response.success || response.data == null) throw AppException(response.message);
    return response.data!;
  }

  @override
  Future<PackagePosDiscountEntity> toggleStatus(int discountId) async {
    final response = await remote.toggleStatus(discountId);
    if (!response.success || response.data == null) throw AppException(response.message);
    return response.data!;
  }

  @override
  Future<void> delete(int discountId) async {
    final response = await remote.delete(discountId);
    if (!response.success) throw AppException(response.message);
  }

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
