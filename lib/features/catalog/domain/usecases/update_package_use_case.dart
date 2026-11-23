import 'package:netsales/features/catalog/domain/entities/package_entity.dart';
import 'package:netsales/features/catalog/domain/entities/update_package_input.dart';
import 'package:netsales/features/catalog/domain/repositories/package_catalog_repository.dart';

/// حالة استخدام تحديث بيانات باقة كروت قائمة عبر كائن النطاق المحدد النوع
class UpdatePackageUseCase {
  final PackageCatalogRepository _repository;

  const UpdatePackageUseCase(this._repository);

  Future<PackageEntity> call(int packageId, UpdatePackageInput input) {
    return _repository.updatePackage(packageId, input);
  }
}
