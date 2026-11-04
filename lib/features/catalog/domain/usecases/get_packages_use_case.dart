import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class GetPackagesUseCase {
  final PackageCatalogRepository _repository;

  const GetPackagesUseCase(this._repository);

  Future<List<PackageEntity>> call({
    int? networkId,
    bool? status,
    String? search,
    int? perPage,
  }) {
    return _repository.getPackages(
      networkId: networkId,
      status: status,
      search: search,
      perPage: perPage,
    );
  }
}

