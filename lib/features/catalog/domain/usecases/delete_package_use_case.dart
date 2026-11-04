import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class DeletePackageUseCase {
  final PackageCatalogRepository _repository;

  const DeletePackageUseCase(this._repository);

  Future<bool> call(int packageId) {
    return _repository.deletePackage(packageId);
  }
}

