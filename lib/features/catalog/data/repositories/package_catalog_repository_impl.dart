import 'package:netsales/core/exceptions/app_exception.dart';
import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/data/datasources/package_catalog_remote_datasource.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// تطبيق مستودع كتالوج باقات الكروت
class PackageCatalogRepositoryImpl implements PackageCatalogRepository {
  final PackageCatalogRemoteDataSource _remoteDataSource;

  const PackageCatalogRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedList<PackageEntity>> getPackages({
    int? networkId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{};
    if (networkId != null) query['network_id'] = networkId;
    if (status != null) query['status'] = status ? '1' : '0';
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (perPage != null) query['per_page'] = perPage;

    final response = await _remoteDataSource.getPackages(
      query: query.isEmpty ? null : query,
    );

    if (response.success && response.data != null) {
      return PaginatedList<PackageEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<PaginatedList<PackageEntity>> getNetworkPackages(
    int networkId, {
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status ? '1' : '0';
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (perPage != null) query['per_page'] = perPage;

    final response = await _remoteDataSource.getNetworkPackages(
      networkId,
      query: query.isEmpty ? null : query,
    );

    if (response.success && response.data != null) {
      return PaginatedList<PackageEntity>(
        items: response.data!,
        nextCursor: response.nextCursor,
        prevCursor: response.prevCursor,
      );
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> getPackageDetails(int packageId) async {
    final response = await _remoteDataSource.getPackageDetails(packageId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> createPackage(Map<String, dynamic> data) async {
    final response = await _remoteDataSource.createPackage(data);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> updatePackage(
    int packageId,
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updatePackage(packageId, data);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<PackageEntity> togglePackageStatus(int packageId) async {
    final response = await _remoteDataSource.togglePackageStatus(packageId);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw AppException(response.message);
  }

  @override
  Future<bool> deletePackage(int packageId) async {
    final response = await _remoteDataSource.deletePackage(packageId);

    if (response.success) {
      return true;
    }

    throw AppException(response.message);
  }
}
