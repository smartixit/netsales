import 'package:netsales/core/models/paginated_list.dart';
import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام جلب قائمة الباقات المفلترة مع الترقيم بالمؤشر
class GetPackagesUseCase {
  final PackageCatalogRepository _repository;

  const GetPackagesUseCase(this._repository);

  Future<PaginatedList<PackageEntity>> call({
    int? networkId,
    int? posId,
    bool? status,
    String? search,
    String? cursor,
    int? perPage,
    List<int>? packageIds,
  }) {
    return _repository.getPackages(
      networkId: networkId,
      posId: posId,
      status: status,
      search: search,
      cursor: cursor,
      perPage: perPage,
      packageIds: packageIds,
    );
  }
}
