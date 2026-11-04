import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

class CreatePackageUseCase {
  final PackageCatalogRepository _repository;

  const CreatePackageUseCase(this._repository);

  Future<PackageEntity> call(Map<String, dynamic> data) {
    return _repository.createPackage(data);
  }
}

