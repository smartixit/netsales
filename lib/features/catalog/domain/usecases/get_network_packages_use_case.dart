import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class GetNetworkPackagesUseCase {
  final PackageCatalogRepository _repository;

  const GetNetworkPackagesUseCase(this._repository);

  Future<List<PackageEntity>> call(
    int networkId, {
    bool? status,
    String? search,
    int? perPage,
  }) {
    return _repository.getNetworkPackages(
      networkId,
      status: status,
      search: search,
      perPage: perPage,
    );
  }
}

