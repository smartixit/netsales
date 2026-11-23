import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام تبديل حالة تفعيل الباقة
class TogglePackageStatusUseCase {
  final PackageCatalogRepository _repository;

  const TogglePackageStatusUseCase(this._repository);

  Future<PackageEntity> call(int packageId) {
    return _repository.togglePackageStatus(packageId);
  }
}
