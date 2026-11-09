import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class GetPackageDetailsUseCase {
  final PackageCatalogRepository _repository;

  const GetPackageDetailsUseCase(this._repository);

  Future<PackageEntity> call(int packageId) {
    return _repository.getPackageDetails(packageId);
  }
}
