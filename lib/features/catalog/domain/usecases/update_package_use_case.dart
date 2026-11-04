import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class UpdatePackageUseCase {
  final PackageCatalogRepository _repository;

  const UpdatePackageUseCase(this._repository);

  Future<PackageEntity> call(int packageId, Map<String, dynamic> data) {
    return _repository.updatePackage(packageId, data);
  }
}

